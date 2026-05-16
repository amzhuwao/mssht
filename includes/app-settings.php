<?php
/**
 * Application settings (database-backed).
 */

function clearAppSettingsCache(): void
{
    unset($GLOBALS['_app_settings_cache'], $GLOBALS['_mail_config_cache']);
}

function getAppSetting(string $key, ?string $default = null): ?string
{
    if (!isset($GLOBALS['_app_settings_cache'])) {
        $GLOBALS['_app_settings_cache'] = [];
        try {
            $db = getDB();
            $rows = $db->query('SELECT setting_key, setting_value FROM app_settings')->fetchAll();
            foreach ($rows as $row) {
                $GLOBALS['_app_settings_cache'][$row['setting_key']] = $row['setting_value'];
            }
        } catch (Exception $e) {
            // Table may not exist before migration
        }
    }
    $cache = $GLOBALS['_app_settings_cache'];
    return array_key_exists($key, $cache) ? $cache[$key] : $default;
}

function setAppSetting(string $key, ?string $value): void
{
    $db = getDB();
    $db->prepare(
        'INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    )->execute([$key, $value]);
    clearAppSettingsCache();
}

function setAppSettings(array $pairs): void
{
    $db = getDB();
    $stmt = $db->prepare(
        'INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?)
         ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)'
    );
    foreach ($pairs as $key => $value) {
        $stmt->execute([$key, $value === null ? null : (string) $value]);
    }
    clearAppSettingsCache();
}

function getMailConfig(): array
{
    if (isset($GLOBALS['_mail_config_cache'])) {
        return $GLOBALS['_mail_config_cache'];
    }

    $defaults = require dirname(__DIR__) . '/config/mail.defaults.php';
    $bool = static fn($v) => filter_var($v, FILTER_VALIDATE_BOOLEAN);

    $GLOBALS['_mail_config_cache'] = [
        'enabled'            => $bool(getAppSetting('mail.enabled', $defaults['enabled'] ? '1' : '0')),
        'from_email'         => getAppSetting('mail.from_email', $defaults['from_email']) ?: $defaults['from_email'],
        'from_name'          => getAppSetting('mail.from_name', $defaults['from_name']) ?: $defaults['from_name'],
        'driver'             => getAppSetting('mail.driver', $defaults['driver']) ?: $defaults['driver'],
        'smtp_host'          => getAppSetting('mail.smtp_host', $defaults['smtp_host']) ?: $defaults['smtp_host'],
        'smtp_port'          => (int) (getAppSetting('mail.smtp_port', (string) $defaults['smtp_port']) ?: $defaults['smtp_port']),
        'smtp_user'          => getAppSetting('mail.smtp_user', $defaults['smtp_user']) ?? '',
        'smtp_pass'          => getAppSetting('mail.smtp_pass', $defaults['smtp_pass']) ?? '',
        'smtp_secure'        => getAppSetting('mail.smtp_secure', $defaults['smtp_secure']) ?: $defaults['smtp_secure'],
        'fallback_show_link' => $bool(getAppSetting('mail.fallback_show_link', $defaults['fallback_show_link'] ? '1' : '0')),
    ];

    return $GLOBALS['_mail_config_cache'];
}

function mailShowFallbackLink(): bool
{
    $c = getMailConfig();
    return !empty($c['fallback_show_link']) || (defined('APP_DEBUG') && APP_DEBUG);
}

function saveMailSettings(array $input): void
{
    $current = getMailConfig();
    $pass = trim($input['smtp_pass'] ?? '');
    if ($pass === '') {
        $pass = $current['smtp_pass'];
    }

    setAppSettings([
        'mail.enabled'            => !empty($input['enabled']) ? '1' : '0',
        'mail.from_email'         => trim($input['from_email'] ?? ''),
        'mail.from_name'          => trim($input['from_name'] ?? ''),
        'mail.driver'             => in_array($input['driver'] ?? '', ['mail', 'smtp'], true) ? $input['driver'] : 'mail',
        'mail.smtp_host'          => trim($input['smtp_host'] ?? ''),
        'mail.smtp_port'          => (string) max(1, (int) ($input['smtp_port'] ?? 587)),
        'mail.smtp_user'          => trim($input['smtp_user'] ?? ''),
        'mail.smtp_pass'          => $pass,
        'mail.smtp_secure'        => in_array($input['smtp_secure'] ?? '', ['tls', 'ssl'], true) ? $input['smtp_secure'] : 'tls',
        'mail.fallback_show_link' => !empty($input['fallback_show_link']) ? '1' : '0',
    ]);
}

function countIntakeGuardianSummaryJobs(int $intakeId, ?int $programId = null): array
{
    $db = getDB();
    $sql = 'SELECT COUNT(DISTINCT CONCAT(sg.guardian_id, "-", s.id)) AS emails,
                   COUNT(DISTINCT s.id) AS students,
                   COUNT(DISTINCT sg.guardian_id) AS guardians
            FROM students s
            JOIN student_guardians sg ON sg.student_id = s.id
            JOIN guardians g ON g.id = sg.guardian_id AND g.receive_summaries = 1
            WHERE s.intake_id = ? AND s.enrollment_status = ?';
    $params = [$intakeId, 'active'];
    if ($programId) {
        $sql .= ' AND s.program_id = ?';
        $params[] = $programId;
    }
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch() ?: ['emails' => 0, 'students' => 0, 'guardians' => 0];
    return [
        'emails'    => (int) $row['emails'],
        'students'  => (int) $row['students'],
        'guardians' => (int) $row['guardians'],
    ];
}
