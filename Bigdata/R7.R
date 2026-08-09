# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R7 : MODÉLISATION PRÉDICTIVE (RANDOM FOREST)
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("randomForest")) install.packages("randomForest")
if (!require("caret")) install.packages("caret")
if (!require("janitor")) install.packages("janitor")

library(tidyverse)
library(randomForest) # Pour le modèle Random Forest
library(caret)        # Pour le partitionnement et la matrice de confusion
library(janitor)      # Pour le nettoyage automatique des noms de colonnes

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/modelisation_importance_variables.png"

cat("Chargement du jeu de données nettoyé pour la modélisation...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 2. NETTOYAGE DES NOMS DE COLONNES (Correction de l'erreur des espaces)
# Remplace "Source Port" par "source_port", "Severity Level" par "severity_level", etc.
df_clean <- df %>% clean_names()

# 3. PRÉPARATION DU DATASET ET FILTRAGE DES TYPES
# Conversion de la cible et des variables catégorielles en Facteurs
df_model <- df_clean %>%
  mutate(severity_level = as.factor(severity_level)) %>%
  select(where(is.numeric), severity_level, protocol, network_segment) %>%
  mutate(across(where(is.character), as.factor)) %>%
  na.omit()

# Split Train (80%) / Test (20%)
set.seed(42)
train_index <- createDataPartition(df_model$severity_level, p = 0.8, list = FALSE)
train_data <- df_model[train_index, ]
test_data  <- df_model[-train_index, ]

# 4. ENTRAÎNEMENT DU MODÈLE RANDOM FOREST
cat("Entraînement du modèle Random Forest en cours...\n")
rf_model <- randomForest(
  severity_level ~ ., 
  data = train_data, 
  ntree = 100, 
  importance = TRUE
)

# 5. ÉVALUATION SUR LE JEU DE TEST
predictions <- predict(rf_model, newdata = test_data)
conf_matrix <- confusionMatrix(predictions, test_data$severity_level)

cat("\n--- PERFORMANCE DU MODÈLE ---\n")
print(conf_matrix$overall['Accuracy'])
cat("-----------------------------\n")

# 6. IMPORTANCE DES VARIABLES ET VISUALISATION
importance_df <- as.data.frame(importance(rf_model)) %>%
  rownames_to_column(var = "Variable") %>%
  arrange(desc(MeanDecreaseGini))

plot_importance <- ggplot(importance_df, aes(x = reorder(Variable, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_col(fill = "firebrick", alpha = 0.85) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Importance des Variables dans la Prédiction de Sévérité",
    subtitle = "Mesurée par le score de pureté (Mean Decrease Gini)",
    x = "Variables",
    y = "Importance (Mean Decrease Gini)"
  )

# 7. Affichage dans RStudio
print(plot_importance)

# 8. Sauvegarde du graphique d'importance
ggsave(output_plot_path, plot = plot_importance, width = 10, height = 6, dpi = 300)

message("✅ Étape R7 terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)