<?php
$root = dirname(__DIR__);
$d = 'div';
$iter = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root));
foreach ($iter as $file) {
    if (!$file->isFile()) continue;
    $path = $file->getPathname();
    if (str_contains($path, DIRECTORY_SEPARATOR . 'tools' . DIRECTORY_SEPARATOR)) continue;
    $ext = strtolower($file->getExtension());
    if (!in_array($ext, ['php', 'html'], true)) continue;
    $content = file_get_contents($path);
    $fixed = str_replace('<motion', '<' . $d, $content);
    $fixed = str_replace('</motion>', '</' . $d . '>', $fixed);
    if ($fixed !== $content) {
        file_put_contents($path, $fixed);
        echo "Fixed: $path\n";
    }
}
