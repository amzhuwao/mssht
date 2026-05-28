<?php
$currentUser = currentUser();
$roleLabel = roleLabel($currentUser['role'] ?? null);
$pageTitle = $pageTitle ?? 'Dashboard';
$tag = 'div';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?> | <?= e(APP_NAME) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <?php if (!empty($extraCss)): foreach ((array)$extraCss as $css): ?>
    <link rel="stylesheet" href="<?= asset('css/' . $css) ?>">
    <?php endforeach; endif; ?>
</head>
<body class="app-body">
    <<?= $tag ?> class="app-wrapper">
        <aside class="sidebar" id="sidebar">
            <<?= $tag ?> class="sidebar-brand">
                <a href="<?= url('dashboard.php') ?>" class="brand-link">
                    <span class="brand-icon">M</span>
                    <span class="brand-text">
                        <strong>MSSHT</strong>
                        <small>School Management</small>
                    </span>
                </a>
            </<?= $tag ?>>
            <nav class="sidebar-nav">
                <?php include __DIR__ . '/navigation.php'; ?>
            </nav>
            <<?= $tag ?> class="sidebar-footer">
                <<?= $tag ?> class="user-mini">
                    <span class="user-avatar"><?= strtoupper(substr($currentUser['first_name'] ?? 'U', 0, 1)) ?></span>
                    <<?= $tag ?> class="user-info">
                        <strong><?= e(($currentUser['first_name'] ?? '') . ' ' . ($currentUser['last_name'] ?? '')) ?></strong>
                        <small><?= e($roleLabel) ?></small>
                    </<?= $tag ?>>
                </<?= $tag ?>>
            </<?= $tag ?>>
        </aside>

        <<?= $tag ?> class="main-content">
            <header class="topbar">
                <button type="button" class="btn-icon sidebar-toggle" id="sidebarToggle" aria-label="Toggle menu">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12h18M3 6h18M3 18h18"/></svg>
                </button>
                <h1 class="page-heading"><?= e($pageTitle) ?></h1>
                <<?= $tag ?> class="topbar-actions">
                    <a href="<?= moduleUrl('messages') ?>" class="btn-icon" title="Messages">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16v12H5.17L4 17.17V4z"/><path d="m4 4 8 6 8-6"/></svg>
                    </a>
                    <<?= $tag ?> class="dropdown">
                        <button type="button" class="btn-user dropdown-toggle" id="userMenuBtn">
                            <span class="user-avatar-sm"><?= strtoupper(substr($currentUser['first_name'] ?? 'U', 0, 1)) ?></span>
                            <span><?= e($currentUser['first_name'] ?? 'User') ?></span>
                        </button>
                        <<?= $tag ?> class="dropdown-menu" id="userMenu">
                            <a href="<?= url('profile.php') ?>">My Profile</a>
                            <a href="<?= url('logout.php') ?>">Sign Out</a>
                        </<?= $tag ?>>
                    </<?= $tag ?>>
                </<?= $tag ?>>
            </header>

            <main class="page-content">
                <?php $flash = getFlash(); if ($flash): ?>
                <<?= $tag ?> class="alert alert-<?= e($flash['type']) ?> alert-dismissible">
                    <?= e($flash['message']) ?>
                    <button type="button" class="alert-close">&times;</button>
                </<?= $tag ?>>
                <?php endif; ?>
