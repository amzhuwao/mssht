            </main>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="<?= asset('js/app.js') ?>"></script>
    <?php if (!empty($extraJs)): foreach ((array)$extraJs as $js): ?>
    <script src="<?= asset('js/' . $js) ?>"></script>
    <?php endforeach; endif; ?>
</body>
</html>
