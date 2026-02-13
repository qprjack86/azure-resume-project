// main.js
// In Azure Static Web Apps, integrated Functions are exposed at /api/* on the same host.
const apiUrl = '/api/VisitorCounter';

document.addEventListener('DOMContentLoaded', () => {
    getVisitorCount();
});

async function getVisitorCount() {
    try {
        const response = await fetch(apiUrl);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();
        document.getElementById('visitor-count').innerText = data.count ?? '0';
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        document.getElementById('visitor-count').innerText = 'Error';
    }
}
