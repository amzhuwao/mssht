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

function sendApplicantPortalCredentialsEmail(string $to, string $name, string $applicationRef, string $portalEmail, string $tempPassword, string $loginUrl): array
{
    $subject = APP_NAME . ' - Your Applicant Portal Details';
    $html = '<div style="background:linear-gradient(135deg,#0d4f4c 0%,#146b68 100%);color:#fff;padding:28px 24px 22px;border-radius:16px 16px 0 0;text-align:center;">'
        . '<div style="display:inline-flex;align-items:center;justify-content:center;width:64px;height:64px;border-radius:18px;background:rgba(255,255,255,.14);font-size:28px;font-weight:700;letter-spacing:.08em;margin-bottom:12px;">M</div>'
        . '<div style="font-size:12px;letter-spacing:.22em;text-transform:uppercase;opacity:.85;">Manica Skyview School of Hospitality and Tourism</div>'
        . '<h2 style="margin:10px 0 0;font-size:28px;line-height:1.1;">Applicant Portal Ready</h2>'
        . '</div>'
        . '<div style="background:#ffffff;border:1px solid #dbe4ee;border-top:none;border-radius:0 0 16px 16px;padding:24px;">'
        . '<p style="margin:0 0 16px;">Hello ' . e($name) . ',</p>'
        . '<p style="margin:0 0 18px;">Your application has been submitted successfully. Keep these details safe to sign in, track progress, and later access your learning materials after approval.</p>'
        . '<div style="background:#f8fafc;border:1px solid #dbe4ee;border-radius:14px;padding:18px 18px 10px;margin:18px 0 20px;">'
        . '<div style="font-size:12px;font-weight:700;letter-spacing:.14em;text-transform:uppercase;color:#0d4f4c;margin-bottom:12px;">Portal Credentials</div>'
        . '<table role="presentation" style="width:100%;border-collapse:collapse;font-size:15px;">'
        . '<tr><td style="padding:8px 0;color:#64748b;width:42%;">Application Ref</td><td style="padding:8px 0;font-weight:700;color:#0f172a;">' . e($applicationRef) . '</td></tr>'
        . '<tr><td style="padding:8px 0;color:#64748b;">Portal Email</td><td style="padding:8px 0;font-weight:700;color:#0f172a;">' . e($portalEmail) . '</td></tr>'
        . '<tr><td style="padding:8px 0;color:#64748b;">Temporary Password</td><td style="padding:8px 0;font-weight:700;color:#0f172a;letter-spacing:.04em;">' . e($tempPassword) . '</td></tr>'
        . '</table>'
        . '</div>'
        . '<p style="margin:0 0 18px;text-align:center;">'
        . '<a href="' . e($loginUrl) . '" style="display:inline-block;padding:13px 26px;background:#0d4f4c;color:#ffffff;text-decoration:none;border-radius:999px;font-weight:700;box-shadow:0 10px 24px rgba(13,79,76,.18);">Sign in to Applicant Portal</a>'
        . '</p>'
        . '<div style="border-top:1px solid #e5edf4;padding-top:14px;color:#475569;font-size:14px;line-height:1.6;">'
        . '<p style="margin:0 0 10px;"><strong>What happens next:</strong> once your application is approved, the same account will unlock learning materials, class tools, and student services automatically.</p>'
        . '<p style="margin:0;">If you did not apply, please ignore this email.</p>'
        . '</div>'
        . '</div>';

    $sent = sendEmail($to, $subject, $html);
    return ['sent' => $sent, 'login_url' => $loginUrl];
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
