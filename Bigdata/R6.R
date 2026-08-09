# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R6 : CLUSTERING & DÉTECTION D'ANOMALIES
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("cluster")) install.packages("cluster")
if (!require("factoextra")) install.packages("factoextra")

library(tidyverse)
library(cluster)     # Pour les algorithmes de clustering
library(factoextra)  # Pour la visualisation avancée des clusters

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/clustering_anomalies.png"

cat("Chargement du jeu de données nettoyé pour le clustering...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 2. PRÉPARATION ET NORMALISATION DES DONNÉES NUMÉRIQUES
# Sélection des variables numériques utiles pour le clustering
df_numeric <- df %>%
  select(where(is.numeric)) %>%
  na.omit()

# Normalisation (centrage-réduction) pour éviter les biais d'échelle
df_scaled <- scale(df_numeric)

# 3. ALGORITHME K-MEANS (Grouping automatique)
set.seed(42) # Pour la reproductibilité
k_clusters <- 3 # Low / Medium / High Risk ou 3 profils distincts

kmeans_res <- kmeans(df_scaled, centers = k_clusters, nstart = 25)

# Ajout des clusters au dataframe d'origine
df_numeric$Cluster <- as.factor(kmeans_res$cluster)

# 4. CALCUL DE DISTANCE AUX CENTROÏDES (Détection des Anomalies/Outliers)
# Les points les plus éloignés du centre de leur cluster sont des anomalies
centers <- kmeans_res$centers[kmeans_res$cluster, ]
distances <- sqrt(rowSums((df_scaled - centers)^2))

# On définit les 5% des points les plus éloignés comme "Anomalies"
seuil_anomalie <- quantile(distances, 0.95)
df_numeric$Anomalie <- ifelse(distances > seuil_anomalie, "Anomalie", "Normal")

# 5. VISUALISATION DES CLUSTERS ET DES ANOMALIES
plot_clusters <- fviz_cluster(
  kmeans_res, 
  data = df_scaled,
  geom = "point",
  ellipse.type = "convex",
  ggtheme = theme_minimal(),
  main = "Clustering K-Means et Isolation des Profils de Menaces"
) +
  scale_color_manual(values = c("#2ecc71", "#f39c12", "#e74c3c")) +
  scale_fill_manual(values = c("#2ecc71", "#f39c12", "#e74c3c"))

plot_anomalies <- ggplot(df_numeric, aes(x = Cluster, fill = Anomalie)) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("Normal" = "gray60", "Anomalie" = "firebrick")) +
  theme_minimal() +
  labs(
    title = "Détection d'Anomalies / Outliers par Cluster",
    subtitle = "Identification des 5% de comportements les plus atypiques",
    x = "Groupes d'Attaques (Clusters)",
    y = "Nombre d'Événements",
    fill = "Statut"
  )

# 6. Affichage dans RStudio
print(plot_clusters)
print(plot_anomalies)

# 7. Sauvegarde du graphique principal
ggsave(output_plot_path, plot = plot_clusters, width = 10, height = 6, dpi = 300)

message("✅ Étape R6 terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)