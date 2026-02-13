// main.js
const api_url = "YOUR_FUNCTION_APP_URL/api/VisitorCounter"; // Update after deploying function

document.addEventListener('DOMContentLoaded', () => {
    getVisitorCount();
});

async function getVisitorCount() {
    try {
        const response = await fetch(api_url);
        const data = await response.json();
        document.getElementById("visitor-count").innerText = data.count;
    } catch (error) {
        console.error("Error fetching visitor count:", error);
        document.getElementById("visitor-count").innerText = "Error";
    }
}