# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R3 : VISUALISATIONS AVANCÉES
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")
if (!require("scales")) install.packages("scales")

library(tidyverse)
library(lubridate)
library(scales) # Pour la gestion des pourcentages et axes

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/analyse_temporelle.png"

cat("Chargement du jeu de données nettoyé...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 2. ANALYSE TEMPORELLE : Pic d'activité par heure
# On cherche à savoir s'il y a des "heures de pointe" pour les attaques
stats_temporelles <- df %>%
  group_by(heure) %>%
  summarise(Total_Attaques = n())

plot_time <- ggplot(stats_temporelles, aes(x = heure, y = Total_Attaques)) +
  geom_line(color = "firebrick", linewidth = 1) +
  geom_area(fill = "firebrick", alpha = 0.2) +
  scale_x_continuous(breaks = 0:23) +
  theme_minimal() +
  labs(
    title = "Évolution des Attaques selon l'Heure de la Journée",
    subtitle = "Analyse des cycles d'activité des menaces",
    x = "Heure (00h - 23h)", 
    y = "Nombre d'Attaques"
  )

# 3. HEATMAP : Sévérité vs Protocole
# Visualisation du niveau de danger par protocole réseau
heatmap_data <- df %>%
  count(Protocol, `Severity Level`)

plot_heatmap <- ggplot(heatmap_data, aes(x = Protocol, y = `Severity Level`, fill = n)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#FFF5F0", high = "#67000D") +
  theme_classic() +
  labs(
    title = "Carte de Chaleur (Heatmap) des Menaces",
    x = "Protocole Réseau", 
    y = "Niveau de Sévérité", 
    fill = "Volume"
  )

# 4. ANALYSE DES SEGMENTS RÉSEAUX
# Répartition proportionnelle de la sévérité par segment réseau
plot_segments <- ggplot(df, aes(x = `Network Segment`, fill = `Severity Level`)) +
  geom_bar(position = "fill") + # Proportions normalisées à 100%
  scale_y_continuous(labels = percent) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Proportion de Sévérité par Segment Réseau",
    x = "Segment Réseau", 
    y = "Pourcentage (%)", 
    fill = "Sévérité"
  )

# 5. Affichage des graphiques dans RStudio
print(plot_time)
print(plot_heatmap)
print(plot_segments)

# 6. Sauvegarde du graphique temporel en haute définition
ggsave(output_plot_path, plot = plot_time, width = 10, height = 6, dpi = 300)

message("✅ Étape R3 terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)