<?php
/**
 * Email sending - MSSHT
 */

function sendEmail(string $to, string $subject, string $htmlBody, ?string $textBody = null): bool
{
    $cfg = getMailConfig();
    if (!$cfg['enabled'] || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
        return false;
    }

    $textBody = $textBody ?? strip_tags(str_replace(['<br>', '<br/>', '<br />'], "\n", $htmlBody));
    $from = $cfg['from_name'] . ' <' . $cfg['from_email'] . '>';

    if ($cfg['driver'] === 'smtp' && $cfg['smtp_host'] && $cfg['smtp_user']) {
        return sendEmailSmtp($to, $subject, $htmlBody, $textBody, $from, $cfg);
    }

    $headers = [
        'MIME-Version: 1.0',
        'Content-type: text/html; charset=UTF-8',
        'From: ' . $from,
        'Reply-To: ' . $cfg['from_email'],
        'X-Mailer: PHP/' . phpversion(),
    ];

    return @mail($to, encodeMailSubject($subject), wrapEmailHtml($htmlBody), implode("\r\n", $headers));
}

function sendTestEmail(string $to): bool
{
    $subject = APP_NAME . ' - Test Email';
    $html = '<h2>Test Email</h2><p>Your MSSHT mail settings are working correctly.</p>'
        . '<p>Sent at ' . date('d M Y H:i:s') . '</p>';
    return sendEmail($to, $subject, $html);
}

function encodeMailSubject(string $subject): string
{
    return '=?UTF-8?B?' . base64_encode($subject) . '?=';
}

function wrapEmailHtml(string $body): string
{
    return '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body style="font-family:Arial,sans-serif;line-height:1.5;color:#333;max-width:600px;margin:0 auto;padding:20px;">'
        . $body
        . '<hr style="margin-top:24px;border:none;border-top:1px solid #eee;"><p style="font-size:12px;color:#888;">'
        . e(APP_FULL_NAME) . '</p></body></html>';
}

function sendEmailSmtp(string $to, string $subject, string $htmlBody, string $textBody, string $from, array $cfg): bool
{
    $host = $cfg['smtp_host'];
    $port = (int) $cfg['smtp_port'];
    $user = $cfg['smtp_user'];
    $pass = $cfg['smtp_pass'];
    $secure = $cfg['smtp_secure'];

    try {
        $socket = $secure === 'ssl'
            ? @stream_socket_client("ssl://{$host}:{$port}", $errno, $errstr, 15)
            : @stream_socket_client("tcp://{$host}:{$port}", $errno, $errstr, 15);
        if (!$socket) {
            return false;
        }

        $read = function () use ($socket) {
            $r = '';
            while ($line = fgets($socket, 515)) {
                $r .= $line;
                if (isset($line[3]) && $line[3] === ' ') {
                    break;
                }
            }
            return $r;
        };
        $write = function ($cmd) use ($socket) {
            fwrite($socket, $cmd . "\r\n");
        };

        $read();
        $write('EHLO localhost');
        $read();
        if ($secure === 'tls') {
            $write('STARTTLS');
            $read();
            stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
            $write('EHLO localhost');
            $read();
        }
        $write('AUTH LOGIN');
        $read();
        $write(base64_encode($user));
        $read();
        $write(base64_encode($pass));
        $read();
        $write('MAIL FROM:<' . $cfg['from_email'] . '>');
        $read();
        $write('RCPT TO:<' . $to . '>');
        $read();
        $write('DATA');
        $read();

        $message = "From: {$from}\r\nTo: {$to}\r\nSubject: " . encodeMailSubject($subject)
            . "\r\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n"
            . wrapEmailHtml($htmlBody) . "\r\n.";
        $write($message);
        $read();
        $write('QUIT');
        fclose($socket);
        return true;
    } catch (Exception $e) {
        return false;
    }
}

function sendPasswordResetEmail(string $to, string $name, string $resetLink, string $portal = 'student'): array
{
    $isStaff = $portal === 'staff';
    $subject = APP_NAME . ' - Password Reset';
    $portalLabel = $isStaff ? 'staff portal' : 'student portal';
    $html = '<h2>Password Reset</h2>'
        . '<p>Hello ' . e($name) . ',</p>'
        . '<p>We received a request to reset your ' . e($portalLabel) . ' password.</p>'
        . '<p><a href="' . e($resetLink) . '" style="display:inline-block;padding:12px 24px;background:#0d4f4c;color:#fff;text-decoration:none;border-radius:6px;">Reset Password</a></p>'
        . '<p>Or copy this link:<br><small>' . e($resetLink) . '</small></p>'
        . '<p>This link expires in 1 hour. If you did not request this, ignore this email.</p>';

    $sent = sendEmail($to, $subject, $html);
    return ['sent' => $sent, 'link' => $resetLink];
}

function createPasswordResetToken(int $userId): string
{
    $db = getDB();
    $token = bin2hex(random_bytes(32));
    $db->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$userId]);
    $db->prepare('INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))')
       ->execute([$userId, $token]);
    return $token;
}

function getPasswordResetUserId(string $token): ?array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT pr.user_id, u.role
         FROM password_resets pr
         JOIN users u ON u.id = pr.user_id
         WHERE pr.token = ? AND pr.expires_at > NOW() AND pr.used_at IS NULL'
    );
    $stmt->execute([$token]);
    $row = $stmt->fetch();
    return $row ?: null;
}
