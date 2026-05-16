<?php
require_once __DIR__ . '/includes/bootstrap.php';

if (isLoggedIn()) {
    redirect(url('dashboard.php'));
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e(APP_FULL_NAME) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/landing.css') ?>">
</head>
<body class="landing-body">
    <header class="landing-header">
        <div class="container landing-nav">
            <a href="<?= url() ?>" class="landing-logo">
                <span class="brand-icon">M</span>
                <span>MSSHT</span>
            </a>
            <nav class="landing-menu">
                <a href="#programs">Programs</a>
                <a href="#features">Features</a>
                <a href="#apply">Apply</a>
                <a href="<?= url('student-login.php') ?>" class="btn btn-outline btn-sm" style="border-color:var(--color-primary);color:var(--color-primary);">Student Portal</a>
                <a href="<?= url('login.php') ?>" class="btn btn-primary btn-sm">Staff Login</a>
            </nav>
        </div>
    </header>

    <section class="hero">
        <div class="hero-bg"></div>
        <div class="container hero-content">
            <p class="hero-eyebrow">Manica Skyview School of Hospitality & Tourism</p>
            <h1>Excellence in Hospitality & Tourism Education</h1>
            <p class="hero-lead">A centralized platform for short courses, professional certificates, diplomas, and HND programs — managing admissions, academics, finance, and student lifecycle.</p>
            <div class="hero-actions">
                <a href="#apply" class="btn btn-primary btn-lg">Apply Online</a>
                <a href="<?= url('student-login.php') ?>" class="btn btn-outline btn-lg">Student Portal</a>
            </div>
        </div>
    </section>

    <section id="programs" class="section programs-section">
        <div class="container">
            <h2 class="section-title">Our Programs</h2>
            <p class="section-subtitle">Flexible pathways from short courses to Higher National Diplomas</p>
            <div class="program-grid">
                <article class="program-card">
                    <span class="program-type">Short Course</span>
                    <h3>Hospitality Operations</h3>
                    <p>Rapid skills training with flexible enrollment and CPD tracking.</p>
                </article>
                <article class="program-card">
                    <span class="program-type">Certificate</span>
                    <h3>Culinary Arts</h3>
                    <p>Professional certification for industry-ready culinary professionals.</p>
                </article>
                <article class="program-card">
                    <span class="program-type">Diploma</span>
                    <h3>Tourism Management</h3>
                    <p>Comprehensive diploma with modular registration and credit accumulation.</p>
                </article>
                <article class="program-card featured">
                    <span class="program-type">HND</span>
                    <h3>Hospitality Management</h3>
                    <p>Industrial attachment, thesis management, and external moderation support.</p>
                </article>
            </div>
        </div>
    </section>

    <section id="features" class="section features-section">
        <div class="container">
            <h2 class="section-title">Integrated School Management</h2>
            <div class="feature-grid">
                <div class="feature-item"><h4>Admissions</h4><p>Online applications, document uploads, and automated workflows.</p></div>
                <div class="feature-item"><h4>LMS</h4><p>Materials, assignments, quizzes, and discussion forums.</p></div>
                <div class="feature-item"><h4>Finance</h4><p>Billing, installments, receipts, and debtor management.</p></div>
                <div class="feature-item"><h4>Examinations</h4><p>CA, exams, GPA, transcripts, and digital certificates.</p></div>
                <div class="feature-item"><h4>Attendance</h4><p>QR attendance, analytics, and lecturer tracking.</p></div>
                <div class="feature-item"><h4>Reporting</h4><p>Academic, financial, and enrollment analytics with exports.</p></div>
            </div>
        </div>
    </section>

    <section id="apply" class="section apply-section">
        <div class="container apply-box">
            <h2>Start Your Application</h2>
            <p>Apply for our January or May intakes. Track your application status online.</p>
            <a href="<?= moduleUrl('admissions', 'apply') ?>" class="btn btn-primary btn-lg">Apply Now</a>
        </div>
    </section>

    <footer class="landing-footer">
        <div class="container">
            <p>&copy; <?= date('Y') ?> <?= e(APP_FULL_NAME) ?>. All rights reserved.</p>
        </div>
    </footer>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
