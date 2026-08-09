# =========================================================================
# PROJET CYBERSÉCURITÉ - ÉTAPE R5 : ANALYSE SPATIALE & GÉOLOCALISATION
# =========================================================================

# 1. Chargement des bibliothèques et des données
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("maps")) install.packages("maps")

library(tidyverse)
library(maps) # Pour les fonds de carte géographiques

# Chemins des fichiers
file_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/cybersecurity_attacks_cleaned.csv"
output_plot_path <- "C:/Users/adamb/Desktop/Auto-formation/Préparation alternance/Alternance cybersecurité/Projets Github cyber/Cyber-surveillance/Bigdata/assets/analyse_spatiale.png"

cat("Chargement du jeu de données nettoyé pour l'analyse spatiale...\n")
df <- read_csv(file_path, show_col_types = FALSE)

# 2. DÉTECTION AUTOMATIQUE DE LA COLONNE DE LOCALISATION
# On cherche dynamiquement la colonne correspondant aux pays/villes
colonne_geo <- intersect(c("Location", "Country", "Geo_Location", "Source IP Address", "Destination IP Address"), colnames(df))[1]

if (is.na(colonne_geo)) {
  # Si aucune colonne texte évidente n'est trouvée, on prend la première colonne type caractere
  colonne_geo <- df %>% select(where(is.character)) %>% colnames() %>% .[1]
}

cat("Colonne utilisée pour l'analyse spatiale :", colonne_geo, "\n")

# 3. TOP 10 DES HOTSPOTS / LOCALISATIONS
top_locations <- df %>%
  group_by(across(all_of(colonne_geo))) %>%
  summarise(
    Total_Attaques = n(),
    Attaques_High = sum(`Severity Level` == "High", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Attaques)) %>%
  slice_head(n = 10)

plot_top_countries <- ggplot(top_locations, aes(x = reorder(.data[[colonne_geo]], Total_Attaques), y = Total_Attaques)) +
  geom_col(fill = "firebrick", alpha = 0.85) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = paste("Top 10 des zones les plus ciblées / sources (via", colonne_geo, ")"),
    subtitle = "Identification des hotspots géographiques majeurs",
    x = colonne_geo,
    y = "Nombre d'Attaques"
  )

# 4. CARTOGRAPHIE MONDIALE (SI LATITUDE ET LONGITUDE SONT PRÉSENTES)
world_map <- map_data("world")

# Vérification présence de coordonnées GPS
has_coords <- all(c("Latitude", "Longitude") %in% colnames(df)) || all(c("lat", "long") %in% colnames(df))

if (has_coords) {
  lat_col <- if("Latitude" %in% colnames(df)) "Latitude" else "lat"
  long_col <- if("Longitude" %in% colnames(df)) "Longitude" else "long"
  
  plot_map <- ggplot() +
    geom_polygon(data = world_map, aes(x = long, y = lat, group = group), 
                 fill = "#e0e0e0", color = "white", linewidth = 0.1) +
    geom_point(data = df, aes(x = .data[[long_col]], y = .data[[lat_col]], color = `Severity Level`), 
               alpha = 0.5, size = 1.5) +
    scale_color_manual(values = c("Low" = "#2ecc71", "Medium" = "#f39c12", "High" = "#e74c3c")) +
    theme_void() +
    labs(
      title = "Distribution Géographique Mondiale des Incidents",
      subtitle = "Cartographie spatiale selon le niveau de sévérité",
      color = "Sévérité"
    ) +
    theme(legend.position = "bottom")
  
} else {
  # Alternative si pas de coordonnées précises GPS : Graphique des Sévérités par zone
  plot_map <- ggplot(top_locations, aes(x = reorder(.data[[colonne_geo]], Total_Attaques), y = Total_Attaques, fill = Attaques_High)) +
    geom_col() +
    scale_fill_gradient(low = "#ffcdd2", high = "#b71c1c") +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Volume d'Attaques et Nouveaux Hotspots Critiques",
      subtitle = paste("Répartition basée sur la colonne :", colonne_geo),
      x = colonne_geo,
      y = "Total Attaques",
      fill = "Sévérité Haute"
    )
}

# 5. Affichage dans RStudio
print(plot_top_countries)
print(plot_map)

# 6. Sauvegarde du graphique principal
ggsave(output_plot_path, plot = plot_map, width = 11, height = 6, dpi = 300)

message("✅ Étape R5 terminée avec succès. Graphique sauvegardé sous :\n", output_plot_path)