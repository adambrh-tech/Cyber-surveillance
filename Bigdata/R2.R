# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R2 : ANALYSE EXPLORATOIRE COMPLÈTE (EDA)
# =========================================================================

# 1. Chargement des packages
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

# 2. Chargement des données nettoyées depuis l'étape R#1
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_stats_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/stats_attaques_R2.csv"

cat("Chargement des données nettoyées...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 3. ANALYSE DES TYPES D'ATTAQUES (Volumes et Risques)
stats_attaques <- df %>%
  group_by(`Attack Type`) %>%
  summarise(
    Nombre = n(),
    Score_Anomalie_Moyen = mean(`Anomaly Scores`, na.rm = TRUE),
    Taux_IoC = mean(ioc_binaire, na.rm = TRUE) * 100
  ) %>%
  arrange(desc(Nombre))

cat("\n--- Résumé par Type d'Attaque ---\n")
print(stats_attaques)

# 4. ANALYSE DE LA SÉVÉRITÉ (Répartition)
stats_severite <- df %>%
  count(`Severity Level`) %>%
  mutate(Pourcentage = n / sum(n) * 100)

cat("\n--- Répartition de la Sévérité ---\n")
print(stats_severite)

# 5. ANALYSE DES PROTOCOLES ET SÉVÉRITÉ
cat("\n--- Tableau de croisement Protocoles x Sévérité ---\n")
table_proto_sev <- table(df$Protocol, df$`Severity Level`)
print(table_proto_sev)

# 6. VISUALISATION (Graphiques ggplot2)

# A. Barplot : Volume des types d'attaques coloré par score d'anomalie
plot_attaques <- ggplot(stats_attaques, aes(x = reorder(`Attack Type`, Nombre), y = Nombre, fill = Score_Anomalie_Moyen)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_gradient(low = "orange", high = "darkred") +
  labs(
    title = "Volume des Attaques et Score d'Anomalie Moyen",
    x = "Type d'Attaque", 
    y = "Nombre d'attaques", 
    fill = "Score Anomalie"
  ) +
  theme_minimal()

# B. Boxplot : Distribution des Scores d'Anomalie par Niveau de Sévérité
plot_boxplot <- ggplot(df, aes(x = `Severity Level`, y = `Anomaly Scores`, fill = `Severity Level`)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "Distribution des Scores d'Anomalie par Niveau de Sévérité",
    x = "Niveau de Sévérité", 
    y = "Score d'Anomalie"
  ) +
  theme_light() +
  theme(legend.position = "none")

# Affichage des graphiques dans RStudio
print(plot_attaques)
print(plot_boxplot)

# 7. SAUVEGARDE DES RÉSULTATS STATISTIQUES
write_csv(stats_attaques, output_stats_path)
cat("\n--- Statistiques R2 sauvegardées sous : ---\n", output_stats_path, "\n")