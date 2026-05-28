<?php
$path = $argv[1] ?? __DIR__ . '/seed_dryrun_output.txt';
if (!file_exists($path)) {
    echo "File not found: $path\n";
    exit(1);
}
$raw = file_get_contents($path);
if (strpos($raw, "\x00") !== false) {
    $conv = @mb_convert_encoding($raw, 'UTF-8', 'UTF-16LE');
    if (!$conv) $conv = @mb_convert_encoding($raw, 'UTF-8', 'UTF-16BE');
    $text = $conv ?: $raw;
} else {
    $text = $raw;
}
$lines = preg_split('/\r\n|\n|\r/', $text);
$tail = array_slice($lines, -200);
foreach ($tail as $ln) echo $ln . PHP_EOL;
