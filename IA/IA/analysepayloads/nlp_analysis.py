
import pandas as pd
import re
from pathlib import Path

# Configuration
DATASET_PATH = r"C:\Users\adamb\Desktop\Auto-formation\Préparation alternance\Alternance cybersecurité\Projets Github cyber\Cyber-surveillance\IA\cybersecurity_attacks_cleaned.csv"

OUTPUT_PATH = r"C:\Users\adamb\Desktop\Auto-formation\Préparation alternance\Alternance cybersecurité\Projets Github cyber\Cyber-surveillance\IA\IA\analysepayloads\results\nlp_results.csv"

# Mots-clés associés aux attaques
SUSPICIOUS_PATTERNS = {
    "SQL Injection": [
        r"union\s+select",
        r"select\s+.*\s+from",
        r"or\s+1\s*=\s*1",
        r"drop\s+table",
        r"insert\s+into"
    ],
    "XSS": [
        r"<script",
        r"javascript:",
        r"onerror\s*=",
        r"onload\s*="
    ],
    "Command Injection": [
        r";\s*cat\s+",
        r"\|\s*whoami",
        r"\b(?:wget|curl)\s+",
        r"\b(?:bash|sh)\s+-c"
    ],
    "Path Traversal": [
        r"\.\./",
        r"\.\.\\"
    ]
}


def clean_payload(payload):
    """Nettoie un payload."""
    if pd.isna(payload):
        return ""

    payload = str(payload).lower()
    payload = re.sub(r"\s+", " ", payload)
    return payload.strip()


def analyze_payload(payload):
    """Détecte les motifs suspects dans un payload."""
    payload = clean_payload(payload)

    detected_attacks = []

    for attack_type, patterns in SUSPICIOUS_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, payload, re.IGNORECASE):
                detected_attacks.append(attack_type)
                break

    score = min(len(detected_attacks) * 25, 100)

    if score >= 50:
        risk = "High"
    elif score >= 25:
        risk = "Medium"
    else:
        risk = "Low"

    return pd.Series({
        "Detected_Attacks": ", ".join(detected_attacks) or "None",
        "Threat_Score": score,
        "Risk_Level": risk
    })


def main():
    print("Chargement du dataset...")

    df = pd.read_csv(DATASET_PATH)

    # Recherche de la colonne contenant les payloads
    possible_columns = [
        col for col in df.columns
        if "payload" in col.lower()
    ]

    if not possible_columns:
        raise ValueError(
            "Aucune colonne Payload trouvée. "
            f"Colonnes disponibles : {list(df.columns)}"
        )

    payload_column = possible_columns[0]
    print(f"Colonne utilisée : {payload_column}")

    print("Analyse NLP des payloads...")

    results = df[payload_column].apply(analyze_payload)

    df = pd.concat([df, results], axis=1)

    # Création du dossier de résultats
    Path("results").mkdir(exist_ok=True)

    df.to_csv(OUTPUT_PATH, index=False)

    print("\nAnalyse terminée.")
    print(f"Résultats enregistrés dans : {OUTPUT_PATH}")

    print("\nRépartition des niveaux de risque :")
    print(df["Risk_Level"].value_counts())


if __name__ == "__main__":
    main()
