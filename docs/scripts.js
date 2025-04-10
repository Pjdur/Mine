document.addEventListener("DOMContentLoaded", function () {
    const footer = document.createElement('footer');
    const currentYear = new Date().getFullYear();
    const lastModified = document.lastModified;

    footer.innerHTML = `&copy; ${currentYear} Mine | Last Modified: ${lastModified}`;
    document.body.appendChild(footer);

    const windowsBtn = document.getElementById('windows-btn');
    const linuxBtn = document.getElementById('linux-btn');
    const slider = document.getElementById('slider');
    const windowsSection = document.getElementById('windows-section');
    const linuxSection = document.getElementById('linux-section');

    if (windowsBtn && linuxBtn && slider && windowsSection && linuxSection) {
        windowsBtn.addEventListener('click', function () {
            slider.style.transform = 'translateX(0)';
        });

        linuxBtn.addEventListener('click', function () {
            slider.style.transform = 'translateX(100%)';
        });
    } else {
        console.error('One or more required elements are missing.');
    }
});