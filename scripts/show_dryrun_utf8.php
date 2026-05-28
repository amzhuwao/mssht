<?php
$path = __DIR__ . '/seed_dryrun_output.txt';
if (!file_exists($path)) {
    echo "No file" . PHP_EOL;
    exit(1);
}
$raw = file_get_contents($path);
// Try convert from UTF-16LE/BE if it seems to contain nulls
if (strpos($raw, "\x00") !== false) {
    $conv = @mb_convert_encoding($raw, 'UTF-8', 'UTF-16');
    if ($conv) {
        echo $conv;
        exit(0);
    }
}
echo $raw;
