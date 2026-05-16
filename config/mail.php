<?php
/**
 * @deprecated Use getMailConfig() from includes/app-settings.php (System Settings UI).
 * Kept for backward compatibility if included directly.
 */
if (!defined('APP_NAME')) {
    require_once __DIR__ . '/app.php';
}
if (!function_exists('getMailConfig')) {
    require_once dirname(__DIR__) . '/includes/app-settings.php';
}
$c = getMailConfig();
if (!defined('MAIL_ENABLED')) {
    define('MAIL_ENABLED', $c['enabled']);
    define('MAIL_FROM_EMAIL', $c['from_email']);
    define('MAIL_FROM_NAME', $c['from_name']);
    define('MAIL_DRIVER', $c['driver']);
    define('MAIL_SMTP_HOST', $c['smtp_host']);
    define('MAIL_SMTP_PORT', $c['smtp_port']);
    define('MAIL_SMTP_USER', $c['smtp_user']);
    define('MAIL_SMTP_PASS', $c['smtp_pass']);
    define('MAIL_SMTP_SECURE', $c['smtp_secure']);
    define('MAIL_FALLBACK_SHOW_LINK', $c['fallback_show_link']);
}
