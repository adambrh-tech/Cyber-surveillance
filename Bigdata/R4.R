# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R4 : ANALYSE TEMPORELLE & TENDANCES
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")
if (!require("zoo")) install.packages("zoo")

library(tidyverse)
library(lubridate)
library(zoo) # Pour le calcul des moyennes mobiles

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/tendances_temporelles.png"

cat("Chargement du jeu de données nettoyé pour l'analyse des tendances...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# conversion sécurisée du timestamp si ce n'est pas déjà fait
if (!"Date" %in% colnames(df)) {
  df <- df %>% mutate(Date = as.Date(Timestamp))
}

# 2. AGRÉGATION QUOTIDIENNE ET MOYENNE MOBILE (7 JOURS)
# Analyse des évolutions journalières et lissage de la tendance de fond
tendances_journalieres <- df %>%
  group_by(Date) %>%
  summarise(
    Total_Attaques = n(),
    Attaques_Critiques = sum(`Severity Level` == "High", na.rm = TRUE)
  ) %>%
  arrange(Date) %>%
  mutate(
    Moyenne_Mobile_7J = rollmean(Total_Attaques, k = 7, fill = NA, align = "right")
  )

# 3. VISUALISATION DES TENDANCES GLOBALES & PICS D'ACTIVITÉ
plot_tendances <- ggplot(tendances_journalieres, aes(x = Date)) +
  geom_line(aes(y = Total_Attaques, color = "Volume Quotidien"), alpha = 0.4, linewidth = 0.8) +
  geom_line(aes(y = Moyenne_Mobile_7J, color = "Moyenne Mobile (7j)"), linewidth = 1.2) +
  scale_color_manual(values = c("Volume Quotidien" = "gray50", "Moyenne Mobile (7j)" = "firebrick")) +
  theme_minimal() +
  labs(
    title = "Évolution Temporelle et Tendance des Cyberattaques",
    subtitle = "Détection des pics d'activité et lissage par moyenne mobile sur 7 jours",
    x = "Date",
    y = "Nombre d'Attaques Journalières",
    color = "Légende"
  ) +
  theme(legend.position = "bottom")

# 4. SEMAINE VS WEEK-END : DYNAMIQUE PAR JOUR DE LA SEMAINE
# Identification des motifs hebdomadaires (saisonnalité)
df_semaine <- df %>%
  mutate(Jour_Semaine = wday(Timestamp, label = TRUE, abbr = FALSE, week_start = 1)) %>%
  group_by(Jour_Semaine, `Severity Level`) %>%
  summarise(Total = n(), .groups = "drop")

plot_hebdo <- ggplot(df_semaine, aes(x = Jour_Semaine, y = Total, fill = `Severity Level`)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  scale_fill_brewer(palette = "Reds") +
  labs(
    title = "Répartition des Menaces selon le Jour de la Semaine",
    subtitle = "Comparaison des niveaux de sévérité du lundi au dimanche",
    x = "Jour de la semaine",
    y = "Volume d'Attaques",
    fill = "Sévérité"
  )

# 5. Affichage des graphiques dans RStudio
print(plot_tendances)
print(plot_hebdo)

# 6. Sauvegarde du graphique principal de tendance
ggsave(output_plot_path, plot = plot_tendances, width = 10, height = 6, dpi = 300)

message("✅ Étape R4 terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)