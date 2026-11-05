"""
EthnoFlora AI — Computational Biodiversity & Conservation Pipeline
Module 3: GBIF Species Occurrence & IUCN Red List Vulnerability Analysis
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

def run_biodiversity_analysis():
    print("=" * 75)
    print("[ETHNOFLORA AI] GBIF MEDICINAL BIODIVERSITY & IUCN CONSERVATION SENTINEL")
    print("=" * 75)

    dataset_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "medicinal_plants.json")
    
    if not os.path.exists(dataset_path):
        print(f"Error: Dataset not found at {dataset_path}")
        return

    with open(dataset_path, "r", encoding="utf-8") as f:
        plants = json.load(f)

    print(f"Loaded {len(plants)} medicinal taxa with GBIF occurrences & Nagoya ABS status.\n")

    iucn_counts = {}
    harvesting_counts = {}

    print(f"{'Scientific Name':<28} | {'Common Name':<16} | {'IUCN Status':<16} | {'Harvesting Policy'}")
    print("-" * 80)

    for p in plants:
        name = p["scientific_name"]
        cname = p["common_name"]
        status = p["iucn_status"]
        harvesting = p["harvesting_risk"]

        iucn_counts[status] = iucn_counts.get(status, 0) + 1
        harvesting_counts[harvesting] = harvesting_counts.get(harvesting, 0) + 1

        print(f"{name:<28} | {cname:<16} | {status:<16} | {harvesting}")

    print("-" * 80)
    print("\n[Conservation Breakdown]:")
    for status, count in sorted(iucn_counts.items(), key=lambda x: x[1], reverse=True):
        pct = (count / len(plants)) * 100
        print(f" * {status:<24}: {count:>2} species ({pct:>5.1f}%)")

    print("\n[Nagoya Protocol Harvesting Governance]:")
    for policy, count in harvesting_counts.items():
        pct = (count / len(plants)) * 100
        print(f" * {policy:<32}: {count:>2} species ({pct:>5.1f}%)")
    print("=" * 75)

if __name__ == "__main__":
    run_biodiversity_analysis()
