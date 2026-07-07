// Inject the brand marks that mdBook has no native option for: the logo +
// wordmark header at the top of the sidebar, and the full wordmark in the top
// menu bar (replacing the plain text title). Done in JS via additional-js so
// the theme template stays un-forked; path_to_root (a per-page global mdBook
// defines) keeps asset and link paths correct at any depth.
(function () {
    function inject() {
        const root = (typeof path_to_root !== 'undefined') ? path_to_root : '';

        const box = document.querySelector('#mdbook-sidebar .sidebar-scrollbox');
        if (box && !box.querySelector('.sidebar-header')) {
            const header = document.createElement('a');
            header.className = 'sidebar-header';
            header.href = root + 'introduction.html';
            header.innerHTML =
                '<img src="' + root + 'assets/logo.png" alt="" aria-hidden="true">'
                + '<span>cli-setup</span>';
            box.insertBefore(header, box.firstChild);
        }

        const title = document.querySelector('.menu-title');
        if (title && !title.querySelector('img')) {
            title.innerHTML =
                '<img class="menu-title-logo" src="' + root + 'assets/logo-full.png" alt="cli-setup">';
        }
    }

    if (document.readyState !== 'loading') {
        inject();
    } else {
        document.addEventListener('DOMContentLoaded', inject);
    }
})();
