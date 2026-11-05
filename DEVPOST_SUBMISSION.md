# 🌿 EthnoFlora AI (एथ्नोफ्लोरा)
### *Computational Ethnopharmacology, Cheminformatics & Biodiversity Intelligence Platform*

**EthnoHack 2026 Official Submission**  
*Organized under the EU Horizon Europe ETHCSTWIN Framework*

---

## 💡 Elevator Pitch
**EthnoFlora AI** bridges ancient indigenous botanical wisdom across 5 global medical traditions (Ayurveda, TCM, Greco-Arab/Dioscorides, African, Amazonian) with modern in-silico cheminformatics, Lipinski Rule of 5 drug screening, IUCN & GBIF geospatial biodiversity telemetry, and clinical cytochrome P450 herb-drug interaction safety engines.

---

## 🎯 The Core Problem & Motivation
Over 80% of the developing world relies on traditional plant-based medicine, and over 40% of modern pharmaceutical blockbusters (including Aspirin, Artemisinin, Metformin, and Paclitaxel) originate from ethnobotanical leads. However:
1. **Traditional Knowledge is Fragmented**: Vernacular names, preparation modes, and indigenous oral traditions are disconnected from scientific taxonomy.
2. **Cheminformatics Bottlenecks**: Natural product drug discovery is hindered by slow access to 2D/3D chemical structures, SMILES strings, and drug-likeness parameters.
3. **Biodiversity & Over-Exploitation**: High-demand medicinal plants face extinction without digital traceability or fair-trade benefit-sharing under the Nagoya Protocol.
4. **Dangerous Clinical Herb-Drug Interactions (HDIs)**: Patients co-administer potent botanical extracts with prescription medications (e.g. Warfarin, Sertraline, Metformin) without knowing of CYP450 enzyme inhibition risks.

---

## 🚀 What EthnoFlora AI Does (The 4 Hackathon Tracks)

### 🌿 Track 1: Traditional Knowledge Mining & Ethnobotany
- **Binomial Taxon Mapping**: Translates vernacular names (Sanskrit, Chinese, Greek, Quechua, Yoruba) to Kew Royal Botanic Gardens Plants of the World Online (POWO) standards.
- **Preparation & Formulation**: Standardizes decoctions, cold infusions, powders, and pastes with historical usage contexts.
- **Interactive 4-Tier Knowledge Graph**: Interactive network connecting:  
  `[Medicinal Plant] ➔ [Phytochemical Metabolite] ➔ [Protein Target] ➔ [Clinical Indication]`

### 🧪 Track 2: Cheminformatics & In-Silico Drug Screening
- **Dynamic 2D / 3D PubChem Architecture**: Live rendering of molecular diagrams and 3D conformers via NCBI PubChem PUG REST API.
- **Lipinski's Rule of 5 Validator**: Automatic real-time computation of Molecular Weight ($<500\text{ Da}$), $\log P$ ($<5$), Hydrogen Bond Donors ($\le 5$), Hydrogen Bond Acceptors ($\le 10$), TPSA, and Rotatable Bonds.
- **One-Click SMILES Export**: Instantly copy canonical SMILES strings and InChIKeys directly to your clipboard for molecular docking pipelines (AutoDock Vina, Schrödinger).

### 🛰️ Track 3: Biodiversity, Geospatial Telemetry & Sustainability
- **GBIF Wild Occurrence Telemetry**: Live interactive coordinate mapping of wild populations across the Himalayas, Western Ghats, Mediterranean basin, and Andes.
- **IUCN Red List Risk Overlays**: Real-time extinction status tagging (*Critically Endangered, Endangered, Vulnerable, Least Concern*).
- **Nagoya Protocol Digital ABS Certificate**: Generates cryptographic Access & Benefit Sharing (ABS) certificates with unique SHA-256 hashes, QR codes, and Clearing-House audit trails to prevent biopiracy and ensure indigenous sovereignty.

### ⚠️ Track 4: Digital Health & Clinical HDI Safety
- **Cytochrome P450 Conflict Matrix**: Clinical decision-support engine screening interactions between 30 prescription drugs (*Warfarin, Metformin, Aspirin, Sertraline, Lisinopril, Digoxin*) and 30 medicinal extracts (*Curcumin, St. John's Wort, Ginkgo, Garlic, Licorice, Ashwagandha*).
- **Severity Stratification**: High Risk (Major / Contraindicated), Moderate Risk (Monitor / Dose Adjustment), Mild / Synergistic.
- **Evidence Grading**: Citations mapped to WHO Monographs, European Medicines Agency (EMA HMPC), and PubMed clinical trials.

### 🤖 PhytoDoc AI (Clinical AI Consultant)
- Conversational pharmacology consultant powered by **Google Gemini 1.5 Pro** with deterministic clinical fallback rules.
- Grounded in evidence-based phytotherapy and pharmacokinetic monographs.

### 📸 Multimodal Botanical AI Specimen Scanner
- Phenotypic computer vision simulator identifying plant vouchers from leaf morphology, venation, and floral anatomy.
- Instant deep-linking from camera snapshot to PhytoChem screening and HDI safety checks.

### ⚡ Reproducible Computational Python Pipeline (`data_pipeline/`)
- Four independent reproducible scripts (`01_traditional_text_miner.py`, `02_cheminformatics_screener.py`, `03_gbif_biodiversity_miner.py`, `04_herb_drug_interaction_validator.py`).
- Complete executed Jupyter Notebook: `data_pipeline/ethnoflora_pipeline.ipynb`.
- In-app interactive pipeline runner with execution timestamps and CLI quick-copy guides.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technologies |
| :--- | :--- |
| **Cross-Platform Client** | Flutter 3.x / Dart 3.x (Web, Android, iOS, Desktop) |
| **Design System** | Neo-Brutalism & Pop-Papercraft (2px black borders, 0-blur drop shadows, pastel badges) |
| **Data Engine** | `EthnoDataService` (In-memory asynchronous caching, fuzzy search, multi-filter indexing) |
| **Cheminformatics API** | NCBI PubChem PUG REST API |
| **Geospatial & Mapping** | OpenStreetMap, `flutter_map`, LatLong2, GBIF Occurrence telemetry |
| **Artificial Intelligence** | Google Gemini 1.5 Pro + Deterministic Rule Fallbacks |
| **Cloud Backend** | Google Cloud Firestore & Supabase Distributed Storage |
| **Scientific Pipeline** | Python 3.10+, Jupyter Notebook, Requests, Pandas |
| **Testing** | Flutter Test SDK (`flutter test test/ethno_data_test.dart`) |

---

## 🏆 Accomplishments & Winning Highlights
1. **Zero Dead Ends**: Every card, search query, filter chip, modal, and structural toggle is interactive and functional.
2. **Dual-Platform Architecture**: Full Flutter GUI accompanied by a scientific command-line Python pipeline and executed Jupyter Notebook.
3. **Ethical Traditional Knowledge Protection**: Built-in Nagoya Protocol ABS certificate generation upholding indigenous sovereignty and benefit-sharing under the UN Convention on Biological Diversity.
4. **Clinical Precision**: Deep CYP450 enzyme conflict detection safeguarding real-world patients against dangerous herb-drug co-prescriptions.

---

## 🧪 Verification & Try It Out
- **Live Localhost Web App**: `http://localhost:8080`
- **Unit Test Suite**: `flutter test test/ethno_data_test.dart` (All 4 test suites pass)
- **Static Code Analysis**: 0 compilation errors across all screens and widgets.
- **Python Pipeline**: `python data_pipeline/02_cheminformatics_screener.py`

---

## 👥 Built With
`flutter` `dart` `pubchem-api` `gemini-pro` `python` `jupyter` `cheminformatics` `ethnopharmacology` `gbif` `iucn-redlist` `nagoya-protocol` `neo-brutalism`
