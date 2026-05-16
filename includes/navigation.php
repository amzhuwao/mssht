<?php
$navItems = [
    'dashboard'  => ['label' => 'Dashboard', 'icon' => 'grid', 'url' => url('dashboard.php')],
    'admissions' => ['label' => 'Admissions', 'icon' => 'user-plus', 'url' => moduleUrl('admissions')],
    'programs'   => ['label' => 'Programs & Courses', 'icon' => 'book', 'url' => moduleUrl('programs')],
    'students'   => ['label' => 'Students (SIS)', 'icon' => 'users', 'url' => moduleUrl('students')],
    'timetable'  => ['label' => 'Timetabling', 'icon' => 'calendar', 'url' => moduleUrl('timetable')],
    'classes'    => ['label' => 'My Classes', 'icon' => 'monitor', 'url' => moduleUrl('classes')],
    'notifications' => ['label' => 'Notifications', 'icon' => 'mail', 'url' => moduleUrl('notifications')],
    'lms'        => ['label' => 'Learning (LMS)', 'icon' => 'monitor', 'url' => moduleUrl('lms')],
    'attendance' => ['label' => 'Attendance', 'icon' => 'check', 'url' => moduleUrl('attendance')],
    'exams'      => ['label' => 'Exams & Assessment', 'icon' => 'file', 'url' => moduleUrl('exams')],
    'finance'    => ['label' => 'Finance', 'icon' => 'dollar', 'url' => moduleUrl('finance')],
    'hr'         => ['label' => 'Human Resources', 'icon' => 'briefcase', 'url' => moduleUrl('hr')],
    'library'    => ['label' => 'Library', 'icon' => 'library', 'url' => moduleUrl('library')],
    'placements' => ['label' => 'Industrial Attachment', 'icon' => 'building', 'url' => moduleUrl('placements')],
    'messages'   => ['label' => 'Communication', 'icon' => 'mail', 'url' => moduleUrl('messages')],
    'reports'    => ['label' => 'Reports & Analytics', 'icon' => 'chart', 'url' => moduleUrl('reports')],
    'graduation' => ['label' => 'Graduation', 'icon' => 'award', 'url' => moduleUrl('graduation')],
    'users'      => ['label' => 'User Management', 'icon' => 'settings', 'url' => moduleUrl('users')],
    'settings'   => ['label' => 'System Settings', 'icon' => 'cog', 'url' => moduleUrl('settings')],
];

$allowed = ROLE_MODULES[currentRole()] ?? [];
$currentModule = $currentModule ?? '';
?>
<ul class="nav-list">
<?php foreach ($navItems as $key => $item):
    if (!in_array($key, $allowed, true)) continue;
    $active = ($currentModule === $key || ($key === 'dashboard' && basename($_SERVER['PHP_SELF']) === 'dashboard.php')) ? 'active' : '';
?>
    <li class="nav-item <?= $active ?>">
        <a href="<?= $item['url'] ?>" class="nav-link" data-icon="<?= $item['icon'] ?>">
            <span class="nav-icon"></span>
            <span><?= e($item['label']) ?></span>
        </a>
    </li>
<?php endforeach; ?>
</ul>
