<?php

function backupDirectory(): string
{
    return defined('BACKUP_PATH') ? BACKUP_PATH : (APP_ROOT . '/backups');
}

function ensureBackupDirectory(): string
{
    $dir = backupDirectory();
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    return $dir;
}

function backupFiles(): array
{
    $dir = ensureBackupDirectory();
    $files = glob($dir . '/*.sql') ?: [];
    usort($files, static function (string $a, string $b): int {
        return filemtime($b) <=> filemtime($a);
    });
    return array_map(static function (string $path): array {
        return [
            'name' => basename($path),
            'path' => $path,
            'size' => filesize($path) ?: 0,
            'modified' => filemtime($path) ?: time(),
        ];
    }, $files);
}

function backupQuoteValue(PDO $db, $value): string
{
    if ($value === null) {
        return 'NULL';
    }
    if (is_bool($value)) {
        return $value ? '1' : '0';
    }
    if (is_int($value) || is_float($value)) {
        return (string) $value;
    }
    return $db->quote((string) $value);
}

function backupFindCreateSql(array $row): string
{
    foreach ($row as $value) {
        if (is_string($value) && stripos($value, 'CREATE TABLE') !== false) {
            return $value;
        }
    }
    return '';
}

function splitSqlStatements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $length = strlen($sql);
    $inSingle = false;
    $inDouble = false;
    $inBacktick = false;
    $escaped = false;

    for ($i = 0; $i < $length; $i++) {
        $char = $sql[$i];
        $buffer .= $char;

        if ($escaped) {
            $escaped = false;
            continue;
        }

        if ($char === '\\') {
            $escaped = true;
            continue;
        }

        if ($char === "'" && !$inDouble && !$inBacktick) {
            $inSingle = !$inSingle;
            continue;
        }

        if ($char === '"' && !$inSingle && !$inBacktick) {
            $inDouble = !$inDouble;
            continue;
        }

        if ($char === '`' && !$inSingle && !$inDouble) {
            $inBacktick = !$inBacktick;
            continue;
        }

        if ($char === ';' && !$inSingle && !$inDouble && !$inBacktick) {
            $stmt = trim(substr($buffer, 0, -1));
            if ($stmt !== '') {
                $statements[] = $stmt;
            }
            $buffer = '';
        }
    }

    $tail = trim($buffer);
    if ($tail !== '') {
        $statements[] = $tail;
    }

    return $statements;
}

function backupDatabase(PDO $db, ?string $filename = null): array
{
    if (function_exists('set_time_limit')) {
        @set_time_limit(0);
    }

    $dir = ensureBackupDirectory();
    $filename = $filename ?: 'mssht-backup-' . date('Ymd-His') . '.sql';
    $filename = preg_replace('/[^A-Za-z0-9._-]+/', '_', $filename);
    if (!str_ends_with(strtolower($filename), '.sql')) {
        $filename .= '.sql';
    }
    $path = $dir . '/' . $filename;

    $handle = fopen($path, 'wb');
    if (!$handle) {
        throw new RuntimeException('Unable to create backup file.');
    }

    $write = static function ($line) use ($handle): void {
        fwrite($handle, $line . PHP_EOL);
    };

    $write('-- MSSHT database backup');
    $write('-- Generated: ' . date('Y-m-d H:i:s'));
    $write('-- Database: ' . DB_NAME);
    $write('SET FOREIGN_KEY_CHECKS=0;');
    $write('');

    $tables = $db->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN) ?: [];
    sort($tables);

    foreach ($tables as $table) {
        $safeTable = str_replace('`', '``', $table);
        $write('-- Table: ' . $table);
        $write('DROP TABLE IF EXISTS `' . $safeTable . '`;');

        $createRow = $db->query('SHOW CREATE TABLE `' . $safeTable . '`')->fetch(PDO::FETCH_ASSOC);
        $createSql = $createRow ? backupFindCreateSql($createRow) : '';
        if ($createSql === '') {
            throw new RuntimeException('Could not read CREATE TABLE for ' . $table);
        }
        $write($createSql . ';');

        $stmt = $db->query('SELECT * FROM `' . $safeTable . '`');
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $columns = array_keys($row);
            $values = array_map(static fn ($value) => backupQuoteValue($db, $value), array_values($row));
            $columnSql = '`' . implode('`,`', array_map(static fn ($col) => str_replace('`', '``', $col), $columns)) . '`';
            $write('INSERT INTO `' . $safeTable . '` (' . $columnSql . ') VALUES (' . implode(', ', $values) . ');');
        }
        $write('');
    }

    $write('SET FOREIGN_KEY_CHECKS=1;');
    fclose($handle);

    return [
        'path' => $path,
        'filename' => $filename,
        'size' => filesize($path) ?: 0,
    ];
}

function restoreDatabase(PDO $db, string $path, bool $dropExisting = true): array
{
    if (function_exists('set_time_limit')) {
        @set_time_limit(0);
    }

    if (!is_file($path)) {
        throw new RuntimeException('Backup file not found: ' . $path);
    }

    $sql = file_get_contents($path);
    if ($sql === false) {
        throw new RuntimeException('Unable to read backup file.');
    }

    $sql = preg_replace('/^\s*(--|#).*$/m', '', $sql) ?? $sql;
    $sql = preg_replace('#/\*.*?\*/#s', '', $sql) ?? $sql;

    if ($dropExisting) {
        $db->exec('SET FOREIGN_KEY_CHECKS=0');
        $tables = $db->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN) ?: [];
        foreach ($tables as $table) {
            $safeTable = str_replace('`', '``', $table);
            $db->exec('DROP TABLE IF EXISTS `' . $safeTable . '`');
        }
        $db->exec('SET FOREIGN_KEY_CHECKS=1');
    }

    $executed = 0;
    foreach (splitSqlStatements($sql) as $statement) {
        $trimmed = trim($statement);
        if ($trimmed === '' || stripos($trimmed, 'SET FOREIGN_KEY_CHECKS') === 0) {
            $db->exec($trimmed);
            continue;
        }
        $db->exec($trimmed);
        $executed++;
    }

    return [
        'path' => $path,
        'executed' => $executed,
    ];
}
