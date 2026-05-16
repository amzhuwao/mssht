<?php
$f = file_get_contents(__DIR__ . '/../includes/pdf.php');
$f = preg_replace('/return str_replace\([^;]+\);\s*\}/', "return \$html;\n}", $f, 1);
file_put_contents(__DIR__ . '/../includes/pdf.php', $f);
echo "fixed\n";
