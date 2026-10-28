import os
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether
from reportlab.graphics.shapes import Drawing, Rect, String

# -----------------------------------------------------------------------------
# CONFIGURATION DU DOCUMENT PDF (Format Paysage 16:9 / Presentation Style)
# -----------------------------------------------------------------------------
pdf_path = os.path.abspath("Presentation_Cybersecurite_BigData.pdf")

# Dimensions A4 Paysage
PAGE_WIDTH, PAGE_HEIGHT = landscape(A4)

doc = SimpleDocTemplate(
    pdf_path,
    pagesize=landscape(A4),
    leftMargin=30,
    rightMargin=30,
    topMargin=30,
    bottomMargin=30
)

# Palette de couleurs Cybersécurité
COLOR_BG_DARK = colors.HexColor("#0F172A")    # Bleu nuit
COLOR_CARD_BG = colors.HexColor("#1E293B")    # Bleu ardoise
COLOR_TEXT_LIGHT = colors.HexColor("#F8FAFC") # Blanc cassé
COLOR_TEXT_MUTED = colors.HexColor("#94A3B8") # Gris
COLOR_PRIMARY = colors.HexColor("#EF4444")    # Rouge
COLOR_SECONDARY = colors.HexColor("#10B981")  # Vert
COLOR_ACCENT = colors.HexColor("#3B82F6")     # Bleu clair

# Styles de texte
styles = getSampleStyleSheet()

style_title_main = ParagraphStyle(
    'MainTitle',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=28,
    leading=34,
    textColor=COLOR_TEXT_LIGHT
)

style_subtitle_main = ParagraphStyle(
    'SubMainTitle',
    parent=styles['Normal'],
    fontName='Helvetica',
    fontSize=14,
    leading=18,
    textColor=COLOR_TEXT_MUTED
)

style_category = ParagraphStyle(
    'Category',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=10,
    leading=12,
    textColor=COLOR_PRIMARY
)

style_slide_title = ParagraphStyle(
    'SlideTitle',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=20,
    leading=24,
    textColor=COLOR_TEXT_LIGHT
)

style_card_title = ParagraphStyle(
    'CardTitle',
    parent=styles['Normal'],
    fontName='Helvetica-Bold',
    fontSize=14,
    leading=18,
    textColor=COLOR_PRIMARY
)

style_body = ParagraphStyle(
    'BodyTextCustom',
    parent=styles['Normal'],
    fontName='Helvetica',
    fontSize=11,
    leading=15,
    textColor=COLOR_TEXT_LIGHT
)

style_body_muted = ParagraphStyle(
    'BodyMutedCustom',
    parent=styles['Normal'],
    fontName='Helvetica',
    fontSize=10,
    leading=14,
    textColor=COLOR_TEXT_MUTED
)

# Fonction d'arrière-plan sombre pour toutes les pages
def draw_background(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(COLOR_BG_DARK)
    canvas.rect(0, 0, PAGE_WIDTH, PAGE_HEIGHT, fill=True, stroke=False)
    canvas.restoreState()

elements = []

# -----------------------------------------------------------------------------
# SLIDE 1 : TITRE & INTRODUCTION
# -----------------------------------------------------------------------------
elements.append(Paragraph("PROJET CYBERSÉCURITÉ", style_category))
elements.append(Spacer(1, 10))
elements.append(Paragraph("Analyse Big Data & Modélisation R", style_title_main))
elements.append(Spacer(1, 15))
elements.append(Paragraph("Traitement des logs d'attaques, détection d'anomalies, Machine Learning & simulations", style_subtitle_main))
elements.append(Spacer(1, 40))

info_text = Paragraph("<font color='#3B82F6'><b>Auteur :</b> Adam  |  <b>Établissement :</b> ISEN Brest  |  <b>Dépôt GitHub :</b> Cyber-surveillance (R1 à R9)</font>", style_body)
elements.append(info_text)
elements.append(Spacer(1, 150)) # Saut de page

# -----------------------------------------------------------------------------
# SLIDE 2 : SOMMAIRE EXÉCUTIF
# -----------------------------------------------------------------------------
elements.append(Paragraph("PHASE 1 : BIG DATA & ANALYSE R", style_category))
elements.append(Spacer(1, 5))
elements.append(Paragraph("Vue d'Ensemble de la Phase Big Data", style_slide_title))
elements.append(Spacer(1, 20))

sommaire_data = [
    [
        Paragraph("<b>01. Fondations & EDA</b><br/><font color='#3B82F6'>Étapes R1 à R3</font><br/><br/><font color='#94A3B8'>Nettoyage des logs, typage, premières visualisations et cartes de chaleur par protocole.</font>", style_body),
        Paragraph("<b>02. Spatio-Temporel</b><br/><font color='#3B82F6'>Étapes R4 & R5</font><br/><br/><font color='#94A3B8'>Lissage par moyenne mobile sur 7 jours, saisonnalité et cartographie mondiale des hotspots.</font>", style_body)
    ],
    [
        Paragraph("<b>03. Machine Learning</b><br/><font color='#3B82F6'>Étapes R6 & R7</font><br/><br/><font color='#94A3B8'>Clustering K-Means, isolation des 5% d'outliers et classification prédictive via Random Forest.</font>", style_body),
        Paragraph("<b>04. Advanced Analytics</b><br/><font color='#3B82F6'>Étapes R8 & R9</font><br/><br/><font color='#94A3B8'>Traitement NLP des payloads texte et simulation financière de risque Monte Carlo (VaR 95%).</font>", style_body)
    ]
]

t_sommaire = Table(sommaire_data, colWidths=[380, 380], rowHeights=[120, 120])
t_sommaire.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), COLOR_CARD_BG),
    ('TEXTCOLOR', (0,0), (-1,-1), colors.white),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('PADDING', (0,0), (-1,-1), 15),
    ('BOTTOMPADDING', (0,0), (-1,-1), 15),
    ('GRID', (0,0), (-1,-1), 10, COLOR_BG_DARK) # Espace entre les cartes
]))

elements.append(t_sommaire)
elements.append(Spacer(1, 80))

# -----------------------------------------------------------------------------
# FONCTION POUR LES SLIDES DÉTAILLÉES (R1 à R9)
# -----------------------------------------------------------------------------
def add_detail_slide(title, subtitle, key_points, tech_summary):
    elements.append(Paragraph("PHASE 1 : BIG DATA & ANALYSE R", style_category))
    elements.append(Spacer(1, 5))
    elements.append(Paragraph(title, style_slide_title))
    elements.append(Spacer(1, 15))
    
    left_content = [Paragraph(f"<b><font color='#3B82F6'>{subtitle}</font></b>", style_body)]
    left_content.append(Spacer(1, 10))
    for pt in key_points:
        left_content.append(Paragraph(f"• {pt}", style_body))
        left_content.append(Spacer(1, 8))
        
    right_content = [
        Paragraph("<font color='#10B981'><b>RÉSUMÉ TECHNIQUE</b></font>", style_body),
        Spacer(1, 10),
        Paragraph(tech_summary.replace("\n", "<br/>"), style_body_muted)
    ]
    
    slide_table = Table([[left_content, right_content]], colWidths=[480, 280])
    slide_table.setStyle(TableStyle([
        ('BACKGROUND', (1,0), (1,0), COLOR_CARD_BG),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 15),
    ]))
    
    elements.append(slide_table)
    elements.append(Spacer(1, 100))

# -----------------------------------------------------------------------------
# SLIDES DE CONTENU
# -----------------------------------------------------------------------------
add_detail_slide(
    "Étape R1 à R3 : Fondations, Nettoyage & EDA",
    "Nettoyage structuré et premières corrélations",
    [
        "Imputation et filtrage rigoureux des valeurs manquantes (NA).",
        "Normalisation des noms de colonnes via janitor::clean_names().",
        "Extraction de variables dérivées : heures, jours, niveaux de sévérité.",
        "Analyse de la répartition des protocoles (TCP, UDP, HTTP) et cartes de chaleur."
    ],
    "Livrable principal :\ncybersecurity_attacks_cleaned.csv\n\nPackages R clés :\ntidyverse, lubridate, janitor, scales."
)

add_detail_slide(
    "Étape R4 : Analyse Temporelle & Tendances",
    "Lissage de tendance et motifs hebdomadaires",
    [
        "Agrégation journalière du volume total d'incidents.",
        "Lissage par Moyenne Mobile (7 jours) avec le package zoo.",
        "Découplage des variations quotidiennes pour dégager la tendance de fond.",
        "Comparaison de l'activité par jour de la semaine (Semaine vs Week-end)."
    ],
    "Visuel produit :\ntendances_temporelles.png\n\nApport Métier :\nPermet au SOC d'anticiper les fenêtres d'attaques récurrentes."
)

add_detail_slide(
    "Étape R5 : Analyse Spatiale & Géolocalisation",
    "Cartographie des Hotspots de menaces",
    [
        "Détection automatique de la colonne géographique (Pays / IP / Localisation).",
        "Extraction du Top 10 des zones émettrices ou ciblées.",
        "Cartographie mondiale interactive ou statique (maps).",
        "Représentation des événements selon le niveau de sévérité."
    ],
    "Visuel produit :\nanalyse_spatiale.png\n\nApport Métier :\nOrientation des règles de filtrage géographique sur les pare-feu."
)

add_detail_slide(
    "Étape R6 : Clustering K-Means & Anomalies",
    "Segmentation non supervisée & isolation d'outliers",
    [
        "Normalisation centrée-réduite des variables numériques (scale).",
        "Groupement automatique en 3 clusters distincts via K-Means.",
        "Calcul de la distance euclidienne de chaque point à son centroïde.",
        "Isolation des 5% de points les plus éloignés comme 'Anomalies'."
    ],
    "Visuel produit :\nclustering_anomalies.png\n\nApport Métier :\nMise en lumière d'attaques complexes non étiquetées."
)

add_detail_slide(
    "Étape R7 : Modélisation Prédictive (Random Forest)",
    "Classification de sévérité en apprentissage supervisé",
    [
        "Partitionnement des données : 80% Entraînement / 20% Test (caret).",
        "Entraînement d'un modèle d'ensemble Random Forest (100 arbres).",
        "Évaluation de la précision (Accuracy) sur la matrice de confusion.",
        "Classement de l'importance des variables par le score de Gini."
    ],
    "Visuel produit :\nmodelisation_importance_variables.png\n\nApport Métier :\nTriage automatique de la priorité des alertes."
)

add_detail_slide(
    "Étape R8 & R9 : Advanced Analytics & Monte Carlo",
    "NLP sur Payloads & Quantification financière du risque",
    [
        "NLP (R8) : Tokenisation des payloads texte, retrait des stop-words et extraction des signatures malveillantes.",
        "Monte Carlo (R9) : 1 000 simulations probabilistes sur 30 jours.",
        "Combinaison des distributions de Poisson, Binomiale et Normale.",
        "Calcul de la valeur médiane du risque et de la Value at Risk (VaR 95%)."
    ],
    "Visuels produits :\nanalyse_nlp_payloads.png\nsimulation_monte_carlo.png\n\nApport Métier :\nTraduction du risque technique en k€ pour la direction."
)

# -----------------------------------------------------------------------------
# SLIDE FINALE : BILAN ET ROADMAP
# -----------------------------------------------------------------------------
elements.append(Paragraph("PHASE 1 : BIG DATA & ANALYSE R", style_category))
elements.append(Spacer(1, 5))
elements.append(Paragraph("Bilan de la Phase 1 & Roadmap", style_slide_title))
elements.append(Spacer(1, 15))

col1_content = [Paragraph("<b><font color='#10B981'>LIVRABLES COMPLÉTÉS (R1 - R9)</font></b>", style_body), Spacer(1, 10)]
for item in ["Pipeline R propre, modulaire et documenté", "7 visuels graphiques haute définition (300 DPI)", "Modèle prédictif Random Forest opérationnel", "Moteur de simulation financière de risques Monte Carlo", "Code entièrement hébergé sur GitHub (Cyber-surveillance)"]:
    col1_content.append(Paragraph(f"✓  {item}", style_body))
    col1_content.append(Spacer(1, 6))

col2_content = [Paragraph("<b><font color='#EF4444'>PROCHAINES ÉTAPES (PHASES 2 & 3)</font></b>", style_body), Spacer(1, 10)]
for item in ["Phase 2 : Exposition des modèles via API REST (Flask/FastAPI)", "Phase 2 : Expliquabilité des modèles avec SHAP / LIME", "Phase 3 : Dashboard Live interactif en temps réel (R Shiny / Web)", "Phase 3 : Déploiement MLOps et automatisation des alertes"]:
    col2_content.append(Paragraph(f"➔  {item}", style_body))
    col2_content.append(Spacer(1, 6))

final_table = Table([[col1_content, col2_content]], colWidths=[380, 380])
final_table.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), COLOR_CARD_BG),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('PADDING', (0,0), (-1,-1), 15),
    ('GRID', (0,0), (-1,-1), 10, COLOR_BG_DARK)
]))

elements.append(final_table)

# Génération du document PDF
doc.build(elements, onFirstPage=draw_background, onLaterPages=draw_background)
print(f"✅ Fichier PDF généré directement avec succès : {pdf_path}")


