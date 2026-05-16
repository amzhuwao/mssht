<?php
/**
 * Error reporting & debug handlers (when APP_DEBUG is enabled)
 */

$logDir = APP_ROOT . '/logs';
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

if (APP_DEBUG) {
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    ini_set('html_errors', '1');
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    ini_set('log_errors', '1');
    ini_set('error_log', $logDir . '/php-errors.log');
}

set_error_handler(function (int $severity, string $message, string $file, int $line): bool {
    if (!(error_reporting() & $severity)) {
        return false;
    }
    throw new ErrorException($message, 0, $severity, $file, $line);
});

set_exception_handler(function (Throwable $e): void {
    $logLine = sprintf(
        "[%s] %s in %s:%d\n",
        date('Y-m-d H:i:s'),
        $e->getMessage(),
        $e->getFile(),
        $e->getLine()
    );
    error_log($logLine . $e->getTraceAsString() . "\n", 3, APP_ROOT . '/logs/php-errors.log');

    if (!APP_DEBUG) {
        http_response_code(500);
        echo '<h1>Something went wrong</h1><p>Please try again later.</p>';
        return;
    }

    http_response_code(500);
    $title = htmlspecialchars(get_class($e), ENT_QUOTES, 'UTF-8');
    $msg = htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8');
    $file = htmlspecialchars($e->getFile(), ENT_QUOTES, 'UTF-8');
    $line = (int) $e->getLine();
    $trace = htmlspecialchars($e->getTraceAsString(), ENT_QUOTES, 'UTF-8');

    $closeBox = '</' . 'div>';
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>Debug: ' . $title . '</title>';
    echo '<style>body{font-family:Consolas,Monaco,monospace;background:#1e1e1e;color:#eee;margin:0;padding:1.5rem;}';
    echo '.box{background:#2d2d2d;border-left:4px solid #e74c3c;padding:1rem 1.25rem;border-radius:6px;margin-bottom:1rem;}';
    echo 'h1{font-size:1.1rem;margin:0 0 .5rem;color:#ff6b6b;}.meta{color:#aaa;font-size:.85rem;}';
    echo 'pre{background:#111;padding:1rem;overflow:auto;font-size:.8rem;border-radius:6px;}</style></head><body>';
    echo '<div class="box"><h1>' . $title . '</h1><p><strong>' . $msg . '</strong></p>';
    echo '<p class="meta">' . $file . ' on line ' . $line . '</p>' . $closeBox;
    echo '<pre>' . $trace . '</pre>';
    echo '<p class="meta"><a href="javascript:history.back()" style="color:#6cb2ff;">&larr; Go back</a></p></body></html>';
});
