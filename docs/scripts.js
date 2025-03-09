document.addEventListener("DOMContentLoaded", function() {
    const footer = document.createElement('footer');
    const currentYear = new Date().getFullYear();
    const lastModified = document.lastModified;

    footer.innerHTML = `&copy; ${currentYear} Mine | Last Modified: ${lastModified}`;
    document.body.appendChild(footer);
});

document.getElementById('windows-btn').addEventListener('click', function() {
    document.getElementById('slider').style.transform = 'translateX(0)';
    document.getElementById('windows-section').style.display = 'block';
    document.getElementById('linux-section').style.display = 'none';
});

document.getElementById('linux-btn').addEventListener('click', function() {
    document.getElementById('slider').style.transform = 'translateX(100%)';
    document.getElementById('windows-section').style.display = 'none';
    document.getElementById('linux-section').style.display = 'block';
});

// Initialize
document.getElementById('windows-section').style.display = 'block';
document.getElementById('linux-section').style.display = 'none';