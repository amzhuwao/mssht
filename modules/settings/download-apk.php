<?php
/**
 * Admin-only Android APK download.
 * File path: storage/mobile/mssht-android-debug.apk
 */
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('settings');
requireRole(['super_admin']);

$apkPath = APP_ROOT . '/storage/mobile/mssht-android-debug.apk';
$downloadName = 'mssht-android-debug.apk';

if (!is_file($apkPath) || !is_readable($apkPath)) {
    flash('danger', 'Android APK is not available on this server yet. Place mssht-android-debug.apk in storage/mobile/.');
    redirect(moduleUrl('settings'));
}

$size = filesize($apkPath);
if ($size === false) {
    flash('danger', 'Could not read the Android APK file.');
    redirect(moduleUrl('settings'));
}

while (ob_get_level() > 0) {
    ob_end_clean();
}

header('Content-Type: application/vnd.android.package-archive');
header('Content-Length: ' . $size);
header('Content-Disposition: attachment; filename="' . $downloadName . '"');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: private, no-store');

$handle = fopen($apkPath, 'rb');
if ($handle === false) {
    flash('danger', 'Could not open the Android APK file.');
    redirect(moduleUrl('settings'));
}

fpassthru($handle);
fclose($handle);
exit;
