
const API_URL = "http://127.0.0.1:8000";

const numberFormat = new Intl.NumberFormat("fr-FR");

async function loadDashboard() {
    const status = document.getElementById("api-status");
    const dot = document.querySelector(".status-dot");

    try {
        const response = await fetch(
            `${API_URL}/api/v1/dashboard/summary`
        );

        if (!response.ok) {
            throw new Error("Erreur API");
        }

        const data = await response.json();

        document.getElementById("total-logs").textContent =
            numberFormat.format(data.total_logs ?? 0);

        document.getElementById("total-attacks").textContent =
            numberFormat.format(data.total_attacks ?? 0);

        document.getElementById("critical-alerts").textContent =
            numberFormat.format(data.critical_alerts ?? 0);

        document.getElementById("model-name").textContent =
            data.model ?? "Non configuré";

        document.getElementById("model-status").textContent =
            "Nom du modèle fourni par l'API";

        status.textContent = "Connectée";
        dot.style.background = "#43d9a3";

        document.getElementById("last-update").textContent =
            "Dernière mise à jour : " +
            new Date().toLocaleTimeString("fr-FR");

    } catch (error) {
        status.textContent = "Déconnectée";
        dot.style.background = "#ff647c";

        document.getElementById("last-update").textContent =
            "API indisponible — vérifie le backend.";

        console.error("Impossible de charger les données :", error);
    }
}

function createCharts() {
    if (typeof Chart === "undefined") {
        console.error("Chart.js n'a pas pu être chargé.");
        return;
    }

    Chart.defaults.color = "#8c9bb5";
    Chart.defaults.font.family = "Segoe UI, Arial, sans-serif";

    new Chart(document.getElementById("activityChart"), {
        type: "line",
        data: {
            labels: ["00h", "04h", "08h", "12h", "16h", "20h"],
            datasets: [{
                label: "Événements",
                data: [18, 12, 35, 26, 48, 32],
                borderColor: "#5b8cff",
                backgroundColor: "rgba(91, 140, 255, 0.12)",
                fill: true,
                tension: 0.4,
                pointRadius: 3
            }, {
                label: "Menaces",
                data: [4, 7, 12, 8, 18, 11],
                borderColor: "#43d9d0",
                backgroundColor: "rgba(67, 217, 208, 0.05)",
                fill: false,
                tension: 0.4,
                pointRadius: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: "bottom",
                    labels: { usePointStyle: true, padding: 20 }
                }
            },
            scales: {
                x: { grid: { color: "#202b40" } },
                y: {
                    beginAtZero: true,
                    grid: { color: "#202b40" }
                }
            }
        }
    });

    new Chart(document.getElementById("threatChart"), {
        type: "doughnut",
        data: {
            labels: ["Réseau", "Authentification", "Payloads", "Autres"],
            datasets: [{
                data: [35, 25, 20, 20],
                backgroundColor: [
                    "#5b8cff",
                    "#43d9d0",
                    "#a78bfa",
                    "#f0b64a"
                ],
                borderColor: "#121b30",
                borderWidth: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: "70%",
            plugins: {
                legend: {
                    position: "bottom",
                    labels: { usePointStyle: true, padding: 16 }
                }
            }
        }
    });
}

document.getElementById("refresh-btn").addEventListener(
    "click",
    loadDashboard
);

createCharts();
loadDashboard();
