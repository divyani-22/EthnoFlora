"""
EthnoFlora AI — Clinical Pharmacovigilance Pipeline
Module 4: Herb-Drug Interaction Matrix & Cytochrome P450 Analysis
EthnoHack 2026 (ETHCSTWIN / Horizon Europe)
"""

import json
import os
import sys

# Ensure UTF-8 output on Windows consoles
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

def run_interaction_validation():
    print("=" * 80)
    print("[ETHNOFLORA AI] CLINICAL HERB-DRUG INTERACTION (HDI) SAFETY VALIDATION")
    print("=" * 80)

    dataset_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "herb_drug_interactions.json")
    
    if not os.path.exists(dataset_path):
        print(f"Error: Dataset not found at {dataset_path}")
        return

    with open(dataset_path, "r", encoding="utf-8") as f:
        interactions = json.load(f)

    print(f"Loaded {len(interactions)} verified clinical herb-drug interactions.\n")

    severity_counts = {}
    evidence_counts = {}

    print(f"{'Herb Name':<18} | {'Prescription Drug':<22} | {'Severity':<10} | {'Evidence Level'}")
    print("-" * 80)

    for i in interactions:
        herb = i["herb_name"]
        drug = i["prescription_drug"]
        sev = i["severity"]
        ev = i["evidence_level"].split(":")[0]  # e.g. Grade A

        severity_counts[sev] = severity_counts.get(sev, 0) + 1
        evidence_counts[ev] = evidence_counts.get(ev, 0) + 1

        print(f"{herb:<18} | {drug:<22} | {sev:<10} | {ev}")

    print("-" * 80)
    print("\n[Severity Distribution]:")
    for sev, count in sorted(severity_counts.items(), key=lambda x: x[1], reverse=True):
        pct = (count / len(interactions)) * 100
        print(f" * {sev:<12}: {count:>2} interactions ({pct:>5.1f}%)")

    print("\n[Evidence Hierarchy (WHO / PubMed / Clinical Consensus)]:")
    for ev, count in sorted(evidence_counts.items()):
        pct = (count / len(interactions)) * 100
        print(f" * {ev:<12}: {count:>2} interactions ({pct:>5.1f}%)")
    print("=" * 80)

if __name__ == "__main__":
    run_interaction_validation()
