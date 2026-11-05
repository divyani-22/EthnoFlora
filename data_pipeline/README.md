# 🌿 EthnoFlora AI — Computational Scientific Pipeline
### *EthnoHack 2026 (ETHCSTWIN / Horizon Europe Framework)*

This directory contains the reproducible computational data science pipelines and in-silico screening scripts supporting the **EthnoFlora AI** mobile and web application.

---

## 📂 Modules & Architecture

| Script | Hackathon Track | Purpose & Methodology |
| :--- | :--- | :--- |
| **`01_traditional_text_miner.py`** | **Track 1: Traditional Knowledge** | NLP entity recognition linking historical Ayurvedic (*Sushruta, Charaka*), Greco-Roman (*Dioscorides*), and TCM (*Ge Hong*) texts to standardized **Kew Gardens POWO taxonomy**. |
| **`02_cheminformatics_screener.py`** | **Track 2: Natural Products & Drug Discovery** | In-silico screening pipeline evaluating **Lipinski's Rule of 5** (MW $\le 500$, $\log P \le 5.0$, HBD $\le 5$, HBA $\le 10$, TPSA) for 30 natural product secondary metabolites. |
| **`03_gbif_biodiversity_miner.py`** | **Track 3: Biodiversity & Sustainability** | Geographic occurrence distribution pipeline cross-referencing species coordinates against **IUCN Red List extinction statuses** and **Nagoya Protocol ABS** harvesting policies. |
| **`04_herb_drug_interaction_validator.py`** | **Track 4: Digital Health & Phytotherapy** | Clinical pharmacovigilance matrix analyzing Cytochrome P450 (CYP3A4, CYP2C9, CYP2D6) conflict distributions and WHO/PubMed evidence levels. |
| **`ethnoflora_pipeline.ipynb`** | **Comprehensive Workflow** | Interactive Jupyter Notebook running statistical summaries, property distributions, and clinical risk segmentations. |

---

## 🚀 Quickstart & Execution

```bash
# 1. Navigate to data pipeline directory
cd data_pipeline

# 2. Run traditional knowledge mining NLP
python 01_traditional_text_miner.py

# 3. Run in-silico cheminformatics screen
python 02_cheminformatics_screener.py

# 4. Run GBIF biodiversity conservation analysis
python 03_gbif_biodiversity_miner.py

# 5. Run clinical Herb-Drug Interaction validator
python 04_herb_drug_interaction_validator.py
```
