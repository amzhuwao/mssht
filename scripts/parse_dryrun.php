<?php
$path = __DIR__ . '/seed_dryrun_output.txt';
if (!file_exists($path)) {
    echo "No dry-run file found\n";
    exit(1);
}
$raw = file_get_contents($path);
// Detect UTF-16 (has many nulls)
if (strpos($raw, "\x00") !== false) {
    // try LE then BE
    $conv = @mb_convert_encoding($raw, 'UTF-8', 'UTF-16LE');
    if (!$conv) {
        $conv = @mb_convert_encoding($raw, 'UTF-8', 'UTF-16BE');
    }
    if ($conv) {
        $text = $conv;
    } else {
        $text = $raw;
    }
} else {
    $text = $raw;
}
$lines = preg_split('/\r\n|\n|\r/', $text);
$tail = array_slice($lines, -200);
foreach ($tail as $ln) {
    echo $ln . PHP_EOL;
}
