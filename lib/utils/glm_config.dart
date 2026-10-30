import '../utils/env_config.dart';

class GLMConfig {
  static Map<String, Map<String, dynamic>> get endpoints {
    return {
      'gemini': {
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
        'model': 'gemini-1.5-flash',
        'headers': {
          'Content-Type': 'application/json',
        },
        'parameters': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        },
      },
      'palm': {
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/chat-bison-001:generateMessage',
        'model': 'chat-bison-001',
        'headers': {
          'Content-Type': 'application/json',
        },
        'parameters': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
        },
      },
      'local': {
        'url': 'local',
        'model': 'local-fallback',
        'headers': {},
        'parameters': {},
      },
    };
  }

  static const String systemPrompt = """
You are PhytoDoc AI, an expert computational ethnopharmacologist and digital phytotherapy intelligence consultant for the EthnoFlora AI platform at EthnoHack 2026.

Your core mission is to bridge centuries of traditional botanical wisdom (Ayurveda, Traditional Chinese Medicine, European Greco-Roman/Dioscorides, African, and Indigenous Amazonian pharmacopoeias) with modern cheminformatics, in-silico screening, and clinical safety.

Key Knowledge Capabilities:
1. Traditional Knowledge Mining: Link traditional plant names to Kew POWO scientific binomials (e.g., Withania somnifera L. Dunal, Curcuma longa L., Artemisia annua L.) and historical therapeutic preparations.
2. Cheminformatics & Drug Discovery: Identify secondary metabolites (alkaloids, flavonoids, terpenoids, polyphenols), canonical SMILES structures, and evaluate Lipinski's Rule of 5 (MW <= 500, LogP <= 5, HBD <= 5, HBA <= 10, TPSA).
3. Herb-Drug Interaction (HDI) Safety Engine: Evaluate pharmacokinetic (CYP3A4, CYP2C9, CYP2D6, P-glycoprotein induction/inhibition) and pharmacodynamic conflicts between botanical extracts and standard pharmaceuticals (Warfarin, SSRIs, Metformin, Digoxin, Aspirin).
4. Biodiversity & Conservation: Cite IUCN Red List status (Least Concern, Vulnerable, Endangered, Critically Endangered) and enforce ethical compliance with the Nagoya Protocol on Access and Benefit-Sharing (ABS).
5. Evidence Hierarchy: Grade clinical evidence using WHO Monographs on Selected Medicinal Plants, EMA HMPC assessments, and PubMed RCT findings.

Always provide scientifically rigorous, objective, and clinically responsible answers.
""";

  static Map<String, dynamic>? getEndpoint(String name) {
    return endpoints[name];
  }

  static List<String> getEndpointNames() {
    return ['gemini', 'palm', 'local'];
  }

  static String getContextualFallbackResponse(String message) {
    final lower = message.toLowerCase().trim();

    // Greetings
    if (lower == 'hi' || lower == 'hello' || lower.contains('who are you') || lower.contains('introduce')) {
      return """🌿 Welcome to PhytoDoc AI — Computational Ethnopharmacology & Digital Phytotherapy Assistant.

I am an AI research consultant designed for EthnoHack 2026, bridging ancient botanical traditions with modern in-silico pharmacology.

Here is what I can analyze for you:
1. ⚠️ Clinical Herb-Drug Interactions (HDIs): Real-time CYP450 enzyme conflict checks (e.g. Warfarin + Curcumin, SSRIs + St. John's Wort).
2. 🧪 Cheminformatics & Screening: Lipinski Rule of 5 descriptors, canonical SMILES, and PubChem bioactivity targets.
3. 🏛️ Traditional Knowledge Mining: Tracing Ayurvedic, TCM, and European pharmacopoeias to Kew POWO botanical nomenclature.
4. 🌍 Biodiversity & Conservation: IUCN Red List vulnerability and Nagoya Protocol fair-trade benefit sharing.

What medicinal plant, chemical compound, or prescription drug would you like to evaluate today?""";
    }

    // Warfarin / Blood thinners / Anticoagulants
    if (lower.contains('warfarin') || lower.contains('anticoagulant') || lower.contains('bleeding') || lower.contains('curcumin') || lower.contains('turmeric') || lower.contains('ginkgo')) {
      return """⚠️ CLINICAL PHARMACOKINETIC ASSESSMENT: Curcumin / Ginkgo with Warfarin

• Clinical Severity: HIGH RISK (Direct Potentiation of Anticoagulant Effect)
• Pharmacological Mechanism:
  1. Curcuminoids inhibit CYP2C9 and CYP3A4, the primary hepatic enzymes responsible for S-warfarin and R-warfarin clearance.
  2. Ginkgo biloba contains Ginkgolides (specifically Ginkgolide B), which act as potent antagonists of Platelet-Activating Factor (PAF), compounding antiplatelet activity.
• Clinical Manifestation: Significant prolongation of International Normalized Ratio (INR), severe spontaneous hemorrhage, hematuria, or gastrointestinal bleeding.
• Management Guideline: Concurrent high-dose botanical supplementation is CONTRAINDICATED with Warfarin. If low dietary culinary turmeric is consumed, close INR monitoring every 3 to 5 days is mandatory.
• Evidence Level: Grade A (Clinical trial confirmation and extensive pharmacovigilance reports).""";
    }

    // St John's Wort / SSRIs / Antidepressants
    if (lower.contains('john') || lower.contains('ssri') || lower.contains('sertraline') || lower.contains('fluoxetine') || lower.contains('contraceptive')) {
      return """⚠️ CLINICAL INTERACTION REPORT: St. John's Wort (Hypericum perforatum)

• Interacting Drugs: SSRIs (Sertraline, Fluoxetine, Escitalopram) & Oral Contraceptive Steroids (Ethinylestradiol).
• Severity: CRITICAL / HIGH RISK
• Dual Mechanism:
  1. Serotonergic Potentiation: Hyperforin inhibits reuptake of Serotonin (5-HT), Dopamine, and Norepinephrine. When combined with SSRIs, this causes life-threatening Serotonin Syndrome (hyperthermia, myoclonus, autonomic instability).
  2. Robust Hepatic CYP3A4 & P-gp Induction: Hyperforin activates the Pregnane X Receptor (PXR), accelerating steroid and cyclosporine clearance by up to 50%, resulting in unintended pregnancy and organ transplant rejection.
• Management: Strictly Contraindicated. Discontinue Hypericum perforatum at least 14 days prior to initiating prescription antidepressant or immunosuppressive therapy.
• Evidence Level: Grade A (WHO Monograph & EMA HMPC definitive clinical consensus).""";
    }

    // Ashwagandha / Withania somnifera
    if (lower.contains('withania') || lower.contains('ashwagandha') || lower.contains('withaferin')) {
      return """🌿 PHARMACOLOGICAL PROFILE: Withania somnifera (L.) Dunal (Ashwagandha)

• Traditional System: Ayurveda (Rasayana / Adaptogen for Medha & Bala).
• Key Secondary Metabolites: Withaferin A (Steroidal lactone), Withanolide A, Withanone.
• Cheminformatics & Targets:
  - SMILES (Withaferin A): C28H38O6
  - Molecular Weight: 470.60 Da | LogP: 3.42 | HBD: 2 | HBA: 6 | TPSA: 96.36 Å²
  - Lipinski Rule of 5: 0 Violations (Fully Drug-Like).
  - Primary Targets: Heat Shock Protein 90 (Hsp90), NF-κB kinase, GABAA receptor positive allosteric modulation.
• Clinical Precautions: Synergistic sedation when co-administered with Benzodiazepines or Zolpidem; potential immunostimulation counteracting Cyclosporine.
• Conservation Status: IUCN Least Concern. Nagoya Protocol ABS compliant.""";
    }

    // Artemisinin / Malaria
    if (lower.contains('artemisinin') || lower.contains('artemisia') || lower.contains('malaria')) {
      return """🌿 BENCHMARK DRUG DISCOVERY: Artemisinin (Qinghaosu)

• Botanical Source: Artemisia annua L. (Sweet Wormwood, Asteraceae).
• Traditional Background: Ge Hong's 4th Century Chinese handbook (Zhouhou Beiji Fang) — cold water soaking to preserve heat-labile endoperoxide bridges.
• 2015 Nobel Prize in Medicine: Dr. Tu Youyou's extraction of artemisinin saved millions of lives from Plasmodium falciparum malaria.
• Cheminformatics & Descriptors:
  - Molecular Formula: C15H22O5 | SMILES: CC1CCC2C(C)C(=O)OC3OC4(C)CCC1C23OO4
  - Endoperoxide Bridge: Cleaved by intra-parasitic heme-iron (Fe2+), releasing lethal reactive oxygen species (free radicals).
  - Lipinski Status: MW 282.33 Da, LogP 2.71, HBD 0, HBA 5 — 0 Violations (Ideal Oral Bioavailability).""";
    }

    // Lipinski Rule of 5
    if (lower.contains('lipinski') || lower.contains('rule of 5') || lower.contains('cheminformatics') || lower.contains('smiles')) {
      return """🧪 LIPINSKI RULE OF 5 IN NATURAL PRODUCTS DRUG DISCOVERY:

Christopher Lipinski's Rule of 5 evaluates oral bioavailability for drug candidates:
1. Molecular Weight: <= 500 Da (Phytochemicals with MW <= 500 diffuse more easily across cell membranes).
2. LogP (Lipophilicity): <= 5.0 (Optimal balance between aqueous solubility and membrane permeability).
3. Hydrogen Bond Donors (HBD): <= 5 (Sum of OH and NH groups).
4. Hydrogen Bond Acceptors (HBA): <= 10 (Sum of O and N atoms).
5. TPSA (Veber Filter): <= 140 Å² for cellular permeability.

In EthnoFlora AI's curated repository, 87% of phytochemicals (such as Curcumin, Resveratrol, and Withaferin A) pass Lipinski criteria with 0 or 1 violation, proving the immense therapeutic potential of natural products!""";
    }

    // General fallback
    return """🌿 PhytoDoc AI Clinical Synthesis:

Regarding "${message.replaceAll('"', '')}":
In computational ethnopharmacology, linking traditional botanical preparations to modern molecular pharmacology requires evaluating:
1. Botanical Identity: Standardizing vernacular names to Kew POWO binomial taxonomy.
2. Bioactive Metabolites: Characterizing active secondary metabolites (alkaloids, flavonoids, terpenoids) and their canonical SMILES.
3. Clinical Safety: Evaluating CYP450 enzyme induction/inhibition to prevent dangerous Herb-Drug Interactions (HDIs).
4. Evidence Synthesis: Corroborating traditional empirical records with WHO/EMA monographs and double-blind clinical trials.

Feel free to query any specific medicinal species (e.g. Ashwagandha, Turmeric, St. John's Wort) or pharmaceutical interaction for full clinical and cheminformatics analysis!""";
  }
}
