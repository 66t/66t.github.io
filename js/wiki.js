document.addEventListener('DOMContentLoaded', () => {
    const menuToggle = document.getElementById('menu-toggle');
    const sidebar = document.getElementById('wiki-sidebar');
    if (menuToggle && sidebar) {
        menuToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('show');
        });
    }
    document.addEventListener('click', (e) => {
        if (window.innerWidth <= 850 && sidebar.classList.contains('show')) {
            if (!sidebar.contains(e.target) && e.target !== menuToggle) {
                sidebar.classList.remove('show');
            }
        }
    });
    const folders = document.querySelectorAll('.folder-toggle');
    folders.forEach(folder => {
        folder.addEventListener('click', function(e) {
            e.preventDefault();
            const subMenu = this.nextElementSibling;
            const icon = this.querySelector('.folder-icon');
            
            if (subMenu.classList.contains('open')) {
                subMenu.classList.remove('open');
                icon.textContent = '+';
            } else {
                subMenu.classList.add('open');
                icon.textContent = '-';
            }
        });
    });
});

