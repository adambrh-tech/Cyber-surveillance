# ==============================================================================
# R#1 : Chargement, Nettoyage, Préprocessing et Sauvegarde
# ==============================================================================

# 1. Packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")

library(tidyverse)
library(lubridate)

# 2. Définition des chemins
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attaks.csv"
output_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"

# 3. Chargement
cat("Chargement du jeu de données...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 4. Nettoyage et Préprocessing
cat("Nettoyage et création des features en cours...\n")
df_processed <- df %>%
  distinct() %>%
  mutate(across(where(is.character), ~replace_na(., "Aucun"))) %>%
  mutate(
    heure = hour(Timestamp),
    jour_semaine = wday(Timestamp, label = TRUE, abbr = FALSE),
    mois = month(Timestamp, label = TRUE),
    is_local_ip = if_else(str_detect(`Source IP Address`, "^(192\\.168\\.|10\\.|172\\.(1[6-9]|2[0-9]|3[0-1]))"), 1, 0),
    ioc_binaire = if_else(`Malware Indicators` == "IoC Detected", 1, 0)
  )

# 5. Exportation en nouveau CSV nettoyé
write_csv(df_processed, output_path)

cat("\n--- Succès ! ---\n")
cat("Le nouveau fichier nettoyé a été enregistré ici :\n", output_path, "\n")
