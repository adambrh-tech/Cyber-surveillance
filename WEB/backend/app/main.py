
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timezone

app = FastAPI(
    title="Cyber-surveillance API",
    description="API de consultation des résultats de détection des cybermenaces",
    version="1.0.0"
)

# Autoriser le frontend à communiquer avec l'API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À restreindre avant la mise en production
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {
        "message": "Bienvenue sur Cyber-surveillance API",
        "status": "running"
    }

@app.get("/api/v1/health")
def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

@app.get("/api/v1/dashboard/summary")
def dashboard_summary():
    # Valeurs temporaires : à remplacer par les résultats Big Data/IA
    return {
        "total_logs": 0,
        "total_attacks": 0,
        "critical_alerts": 0,
        "model": "Random Forest",
        "message": "Les résultats réels seront connectés ensuite."
    }
