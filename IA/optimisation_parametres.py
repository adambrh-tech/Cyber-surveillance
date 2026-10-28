
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.pipeline import Pipeline

# 1. Charger les données
df = pd.read_csv("cybersecurity_attacks_cleaned.csv")

# 2. Définir la cible
target = "Attack Type"
X = df.drop(columns=[target])
y = df[target]

# 3. Retirer les colonnes non utilisées
colonnes_a_supprimer = [
    "Timestamp",
    "Source IP Address",
    "Destination IP Address",
    "Payload Data",
    "User Information",
    "Device Information",
    "Geo-location Data",
    "Proxy Information",
    "Firewall Logs",
    "IDS/IPS Alerts"
]

X = X.drop(
    columns=[c for c in colonnes_a_supprimer if c in X.columns]
)

# 4. Préparer les colonnes catégorielles
colonnes_categorielles = X.select_dtypes(
    include=["object", "category"]
).columns

preprocesseur = ColumnTransformer(
    transformers=[
        (
            "cat",
            OneHotEncoder(handle_unknown="ignore"),
            colonnes_categorielles
        )
    ],
    remainder="passthrough"
)

# 5. Créer le pipeline
pipeline = Pipeline([
    ("preprocessing", preprocesseur),
    ("random_forest", RandomForestClassifier(
        random_state=42,
        n_jobs=1
    ))
])

# 6. Séparer les données
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

# 7. Définir les hyperparamètres à tester
parametres = {
    "random_forest__n_estimators": [100, 200, 300],
    "random_forest__max_depth": [None, 10, 20, 30],
    "random_forest__min_samples_split": [2, 5, 10],
    "random_forest__min_samples_leaf": [1, 2, 4]
}

# 8. Rechercher la meilleure configuration
recherche = GridSearchCV(
    estimator=pipeline,
    param_grid=parametres,
    cv=5,
    scoring="accuracy",
    n_jobs=-1,
    verbose=2
)

print("Optimisation des hyperparamètres en cours...")
recherche.fit(X_train, y_train)

# 9. Afficher le résultat de l'optimisation
print("\nMeilleurs hyperparamètres :")
print(recherche.best_params_)

print("\nMeilleur score de validation croisée :")
print(f"{recherche.best_score_ * 100:.2f} %")

# 10. Récupérer le meilleur modèle
meilleur_modele = recherche.best_estimator_

print("\nOptimisation terminée.")
