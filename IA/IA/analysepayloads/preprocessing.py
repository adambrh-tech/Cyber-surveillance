
import re
import pandas as pd
from pathlib import Path

# ============================================================
# CONFIGURATION
# ============================================================

DATASET_PATH = Path(
    r"C:\Users\adamb\Desktop\Auto-formation\Préparation alternance\Alternance cybersecurité\Projets Github cyber\Cyber-surveillance\IA\cybersecurity_attacks_cleaned.csv"
)

OUTPUT_PATH = Path(
    r"C:\Users\adamb\Desktop\Auto-formation\Préparation alternance\Alternance cybersecurité\Projets Github cyber\Cyber-surveillance\IA\IA\analysepayloads\results\payloads_preprocessed.csv"
)

# ============================================================
# NETTOYAGE DES PAYLOADS
# ============================================================

def clean_payload(payload):
    """
    Nettoie et normalise un payload.
    Conserve les caractères spéciaux utiles à la détection
    des attaques (SQL Injection, XSS, Command Injection...).
    """

    if pd.isna(payload):
        return ""

    payload = str(payload)

    # Supprimer les caractères de contrôle invisibles
    payload = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", " ", payload)

    # Uniformiser les espaces
    payload = re.sub(r"\s+", " ", payload)

    # Supprimer les espaces au début et à la fin
    payload = payload.strip()

    # Normaliser la casse
    payload = payload.lower()

    return payload


# ============================================================
# PRÉTRAITEMENT DU DATASET
# ============================================================

def preprocess_dataset(df, payload_column):
    """
    Prépare la colonne Payload pour l'analyse NLP.
    """

    df = df.copy()

    # Nettoyage des valeurs manquantes
    df[payload_column] = df[payload_column].fillna("")

    # Nettoyage des payloads
    df["Payload_Cleaned"] = df[payload_column].apply(clean_payload)

    # Longueur des payloads
    df["Payload_Length"] = df["Payload_Cleaned"].str.len()

    # Indicateur de présence d'un payload
    df["Has_Payload"] = df["Payload_Cleaned"].ne("")

    return df


# ============================================================
# PROGRAMME PRINCIPAL
# ============================================================

def main():

    print("Chargement du dataset...")

    if not DATASET_PATH.exists():
        raise FileNotFoundError(
            f"Dataset introuvable : {DATASET_PATH}"
        )

    df = pd.read_csv(DATASET_PATH)

    print(f"Dataset chargé : {df.shape[0]} lignes")

    # Recherche automatique de la colonne Payload
    payload_columns = [
        col for col in df.columns
        if "payload" in col.lower()
    ]

    if not payload_columns:
        print("Aucune colonne Payload détectée.")
        print("Colonnes disponibles :", df.columns.tolist())
        return

    payload_column = payload_columns[0]

    print(f"Colonne utilisée : {payload_column}")

    # Prétraitement
    df = preprocess_dataset(df, payload_column)

    # Création du dossier de sortie
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Export
    df.to_csv(OUTPUT_PATH, index=False, encoding="utf-8-sig")

    print("\nPrétraitement terminé.")
    print(f"Nombre de lignes : {len(df)}")
    print(f"Payloads non vides : {df['Has_Payload'].sum()}")
    print(f"Résultats enregistrés dans : {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
