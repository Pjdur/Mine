document.addEventListener("DOMContentLoaded", function() {
    const footer = document.createElement('footer');
    const currentYear = new Date().getFullYear();
    const lastModified = document.lastModified;

    footer.innerHTML = `&copy; ${currentYear} Mine | Last Modified: ${lastModified}`;
    document.body.appendChild(footer);
});