# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R8 : ANALYSE NLP DES PAYLOADS & TEXTES
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("tidytext")) install.packages("tidytext")
if (!require("janitor")) install.packages("janitor")

library(tidyverse)
library(tidytext)  # Pour la tokenisation et le traitement NLP
library(janitor)   # Pour un nommage propre des variables

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/analyse_nlp_payloads.png"

cat("Chargement du jeu de données nettoyé pour l'analyse NLP...\n")
df <- read_csv(file_path, show_col_types = FALSE) %>% clean_names()

# 2. DÉTECTION DE LA COLONNE TEXTE / PAYLOAD
# Recherche automatique d'une colonne contenant du texte descriptif ou payload
cols_texte_possibles <- c("payload", "attack_type", "description", "log_message", "packet_data")
col_texte <- intersect(cols_texte_possibles, colnames(df))[1]

if (is.na(col_texte)) {
  # Si non trouvée, on prend la première colonne de type caractère
  col_texte <- df %>% select(where(is.character)) %>% colnames() %>% .[1]
}

cat("📌 Colonne analysée en NLP :", col_texte, "\n")

# 3. TOKENISATION ET EXTRACTION DES MOTS-CLÉS (TERMES LES PLUS FRÉQUENTS)
tokens <- df %>%
  mutate(id_incident = row_number()) %>%
  select(id_incident, severity_level, text_target = all_of(col_texte)) %>%
  filter(!is.na(text_target)) %>%
  unnest_tokens(word, text_target) %>%
  # Suppression des mots vides anglais standards (stop words)
  anti_join(stop_words, by = "word") %>%
  # Conservation des termes alphabétiques de plus de 2 lettres
  filter(str_detect(word, "^[a-z]{3,}$"))

# Top 15 des termes / signatures les plus récurrents
top_mots <- tokens %>%
  count(word, sort = TRUE) %>%
  slice_max(n, n = 15)

# 4. MATRICE DE FRÉQUENCE / MAPPING PAR SÉVÉRITÉ (SCORING)
mots_par_severite <- tokens %>%
  count(severity_level, word) %>%
  group_by(word) %>%
  filter(sum(n) > 5) %>% # On ne garde que les mots qui apparaissent plus de 5 fois
  ungroup() %>%
  filter(word %in% top_mots$word)

# 5. VISUALISATION DES MOTS-CLÉS PAR NIVEAU DE SÉVÉRITÉ
plot_nlp <- ggplot(mots_par_severite, aes(x = reorder(word, n), y = n, fill = severity_level)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Low" = "#2ecc71", "Medium" = "#f39c12", "High" = "#e74c3c")) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = paste("Analyse NLP : Signatures et Mots-clés Suspects (via", col_texte, ")"),
    subtitle = "Fréquence des termes associés selon le niveau de sévérité",
    x = "Mots-clés / Termes extraits",
    y = "Nombre d'occurrences",
    fill = "Sévérité"
  )

# 6. Affichage dans RStudio
print(plot_nlp)

# 7. Sauvegarde du graphique d'analyse NLP
ggsave(output_plot_path, plot = plot_nlp, width = 10, height = 6, dpi = 300)

message("✅ Étape R8 (NLP) terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)