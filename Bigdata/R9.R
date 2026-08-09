# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R9 : SIMULATION & SCÉNARIOS (MONTE CARLO)
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("janitor")) install.packages("janitor")

library(tidyverse)
library(janitor)

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/simulation_monte_carlo.png"

cat("Chargement du jeu de données nettoyé pour les simulations...\n")
df <- read_csv(file_path, show_col_types = FALSE) %>% clean_names()

# 2. CALCUL DES PARAMÈTRES HISTORIQUES (PROBABILITÉS & COÛTS ESTIMÉS)
# Estimation de la proportion d'attaques à haute sévérité
prop_high <- mean(df$severity_level == "High", na.rm = TRUE)
if (is.nan(prop_high) || is.na(prop_high)) prop_high <- 0.25 # Valeur par défaut si non disponible

cat("Proportion d'attaques de sévérité haute (historique) :", round(prop_high * 100, 2), "%\n")

# Paramètres financiers simulés (Coût moyen d'un incident élevé)
cout_moyen_high <- 15000  # ex: 15 000 € par incident critique
sd_cout_high    <- 3000   # Écart-type du coût

# 3. SIMULATION MONTE CARLO (1 000 SCÉNARIOS SUR 30 JOURS)
set.seed(42)
n_simulations <- 1000
jours_simules  <- 30
moyenne_attaques_jour <- nrow(df) / ifelse(n_distinct(df$date) > 0, n_distinct(df$date), 30)

simulations_results <- map_df(1:n_simulations, function(sim_id) {
  # Nombre d'attaques par jour généré selon une loi de Poisson
  attaques_par_jour <- rpois(jours_simules, lambda = moyenne_attaques_jour)
  
  # Nombre d'attaques critiques simulées (Binomiale)
  attaques_high <- rbinom(jours_simules, size = attaques_par_jour, prob = prop_high)
  
  # Estimation du coût financier total pour ce scénario
  cout_total <- sum(rnorm(sum(attaques_high), mean = cout_moyen_high, sd = sd_cout_high))
  
  tibble(
    simulation_id = sim_id,
    total_incidents_critiques = sum(attaques_high),
    impact_financier_eur = cout_total
  )
})

# 4. STATISTIQUES DES SCÉNARIOS & RISQUE À LA VALEUR (VaR 95%)
var_95 <- quantile(simulations_results$impact_financier_eur, 0.95, na.rm = TRUE)
cout_median <- median(simulations_results$impact_financier_eur, na.rm = TRUE)

cat("\n--- RÉSULTATS DES SIMULATIONS MONTE CARLO ---\n")
cat("Coût financier médian simulé (30 jours) :", round(cout_median, 2), "€\n")
cat("Value at Risk (VaR 95%) - Pire scénario (95%) :", round(var_95, 2), "€\n")
cat("--------------------------------------------\n")

# 5. VISUALISATION DES DISTRIBUTIONS DE RISQUE
plot_monte_carlo <- ggplot(simulations_results, aes(x = impact_financier_eur / 1000)) +
  geom_histogram(bins = 40, fill = "#3498db", color = "white", alpha = 0.7) +
  geom_vline(xintercept = cout_median / 1000, color = "#2ecc71", linetype = "dashed", linewidth = 1.2) +
  geom_vline(xintercept = var_95 / 1000, color = "#e74c3c", linetype = "solid", linewidth = 1.2) +
  theme_minimal() +
  labs(
    title = "Simulation Monte Carlo : Estimation du Risque Financier (30 Jours)",
    subtitle = paste("Médiane (Vert) :", round(cout_median / 1000, 1), "k€ | VaR 95% (Rouge) :", round(var_95 / 1000, 1), "k€"),
    x = "Impact Financier Estimé (en milliers d'Euros - k€)",
    y = "Fréquence des Scénarios"
  )

# 6. Affichage dans RStudio
print(plot_monte_carlo)

# 7. Sauvegarde du graphique de simulation
ggsave(output_plot_path, plot = plot_monte_carlo, width = 10, height = 6, dpi = 300)

message("✅ Étape R9 (Monte Carlo) terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)