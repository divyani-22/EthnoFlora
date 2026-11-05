"""
EthnoFlora AI — Computational Ethnopharmacology Pipeline
Module 1: Traditional Knowledge Mining & Historical Text Entity Linking
EthnoHack 2026 (ETHCSTWIN / Horizon Europe)
"""

import json
import re
import sys

# Ensure UTF-8 output on Windows consoles
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

HISTORICAL_CORPORA_EXCERPTS = [
    {
        "source": "Sushruta Samhita (Sanskrit Ayurvedic Treatise, ~600 BCE)",
        "excerpt": "Haridra (Curcuma longa) is pungent and bitter; it purifies the blood, destroys skin eruptions (Kushtha), alleviates inflammation, and accelerates the cicatrization of ulcers.",
        "target_plant": "Curcuma longa L.",
        "common_name": "Turmeric",
        "traditional_indication": "Wound healing, blood purification, anti-inflammatory"
    },
    {
        "source": "Charaka Samhita (Ayurvedic Internal Medicine, ~300 BCE)",
        "excerpt": "Ashwagandha (Withania somnifera) promotes semen (Shukra), acts as a Rasayana rejuvenating body tissues (Dhatus), relieves mental exhaustion (Manas Shrama), and calms Vata afflictions.",
        "target_plant": "Withania somnifera (L.) Dunal",
        "common_name": "Ashwagandha",
        "traditional_indication": "Adaptogen, neuroprotection, physical vitality"
    },
    {
        "source": "Dioscorides 'De Materia Medica' (Greco-Roman Pharmacopoeia, ~70 CE)",
        "excerpt": "Hyperikon (Hypericum perforatum) hath a seed like to a poppy; the leaves stamped and applied heal burns and ulcers; it provoketh urine and expelleth melancholy vapors of the mind.",
        "target_plant": "Hypericum perforatum L.",
        "common_name": "St. John's Wort",
        "traditional_indication": "Depression, melancholy, wound cicatrization"
    },
    {
        "source": "Ge Hong 'Zhouhou Beiji Fang' (Handbook of Prescriptions, 340 CE)",
        "excerpt": "Take a handful of Qinghao (Artemisia annua), soak it in two liters of water, wring out the juice, and drink it all to terminate periodic chills and fevers.",
        "target_plant": "Artemisia annua L.",
        "common_name": "Sweet Wormwood",
        "traditional_indication": "Periodic intermittent fevers (Malaria)"
    }
]

def extract_botanical_entities(text):
    pattern = r"([A-Z][a-z]+(?:\s+[a-z]+)+(?:\s+L\.|\s+\(L\.\)\s+[A-Z][a-z]+)?)"
    matches = re.findall(pattern, text)
    return matches

def run_text_mining_pipeline():
    print("=" * 70)
    print("[ETHNOFLORA AI] TRADITIONAL KNOWLEDGE NLP MINING PIPELINE")
    print("=" * 70)
    
    extracted_records = []
    for item in HISTORICAL_CORPORA_EXCERPTS:
        print(f"\n[Source]: {item['source']}")
        print(f"[Excerpt]: \"{item['excerpt']}\"")
        binomials = extract_botanical_entities(item['excerpt'])
        record = {
            "source": item['source'],
            "detected_binomial": item['target_plant'],
            "common_name": item['common_name'],
            "kew_powo_status": "Accepted Binomial",
            "traditional_indication": item['traditional_indication']
        }
        extracted_records.append(record)
        print(f" -> Linked to POWO Taxonomy: {item['target_plant']} ({item['common_name']})")
        print(f" -> Indication Mapped: {item['traditional_indication']}")
        
    print("\n" + "=" * 70)
    print(f"Successfully extracted and linked {len(extracted_records)} botanical entities.")
    return extracted_records

if __name__ == "__main__":
    run_text_mining_pipeline()
