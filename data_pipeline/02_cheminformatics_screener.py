"""
EthnoFlora AI — Computational Cheminformatics Screening Pipeline
Module 2: Lipinski Rule of 5 Evaluation & Molecular Descriptors
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

def evaluate_lipinski_rule_of_5(mw, logp, hbd, hba, tpsa, rotbonds):
    violations = 0
    reasons = []

    if mw > 500.0:
        violations += 1
        reasons.append(f"MW {mw} > 500 Da")
    if logp > 5.0:
        violations += 1
        reasons.append(f"LogP {logp} > 5.0")
    if hbd > 5:
        violations += 1
        reasons.append(f"HBD {hbd} > 5")
    if hba > 10:
        violations += 1
        reasons.append(f"HBA {hba} > 10")

    is_druglike = violations <= 1
    return {
        "violations": violations,
        "is_druglike": is_druglike,
        "reasons": reasons
    }

def run_cheminformatics_screen():
    print("=" * 75)
    print("[ETHNOFLORA AI] IN-SILICO PHYTOCHEMICAL CHEMINFORMATICS SCREEN")
    print("=" * 75)

    dataset_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "phytochemicals.json")
    
    if not os.path.exists(dataset_path):
        print(f"Error: Dataset not found at {dataset_path}")
        return

    with open(dataset_path, "r", encoding="utf-8") as f:
        compounds = json.load(f)

    print(f"Loaded {len(compounds)} secondary metabolites from PubChem / IMPPAT repository.\n")

    druglike_count = 0
    total_mw = 0.0

    print(f"{'Compound':<22} | {'MW (Da)':<8} | {'LogP':<6} | {'HBD':<4} | {'HBA':<4} | {'TPSA':<6} | {'Lipinski Status'}")
    print("-" * 75)

    for c in compounds:
        mw = c["molecular_weight"]
        logp = c["logp"]
        hbd = c["h_bond_donors"]
        hba = c["h_bond_acceptors"]
        tpsa = c["tpsa"]
        rotbonds = c["rotatable_bonds"]

        eval_res = evaluate_lipinski_rule_of_5(mw, logp, hbd, hba, tpsa, rotbonds)
        total_mw += mw

        if eval_res["is_druglike"]:
            druglike_count += 1
            status = f"PASS ({eval_res['violations']} viol.)"
        else:
            status = f"FAIL ({eval_res['violations']} viol.)"

        print(f"{c['name']:<22} | {mw:<8.1f} | {logp:<6.2f} | {hbd:<4} | {hba:<4} | {tpsa:<6.1f} | {status}")

    pct_druglike = (druglike_count / len(compounds)) * 100
    avg_mw = total_mw / len(compounds)

    print("-" * 75)
    print(f"\nSummary Statistics:")
    print(f" * Total Phytochemicals Analyzed: {len(compounds)}")
    print(f" * Average Molecular Weight:     {avg_mw:.2f} Da")
    print(f" * Lipinski Drug-Like Candidates:  {druglike_count}/{len(compounds)} ({pct_druglike:.1f}%)")
    print("=" * 75)

if __name__ == "__main__":
    run_cheminformatics_screen()
