<?php
/**
 * Default mail settings (overridden by System Settings UI / app_settings table).
 */
return [
    'enabled'            => true,
    'from_email'         => 'noreply@mssht.ac.zw',
    'from_name'          => defined('APP_NAME') ? APP_NAME : 'MSSHT',
    'driver'             => 'mail',
    'smtp_host'          => 'smtp.gmail.com',
    'smtp_port'          => 587,
    'smtp_user'          => '',
    'smtp_pass'          => '',
    'smtp_secure'        => 'tls',
    'fallback_show_link' => true,
];
