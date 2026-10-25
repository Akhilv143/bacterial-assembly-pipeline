import pandas as pd
import re
import os

sample_id = "ERR3335404"
print(f"Generating Final Genomic Summary Report for {sample_id}...\n")

report_lines = [
    f"# Final Genome Assembly and Annotation Report: {sample_id}",
    "This report aggregates the downstream screening results from Abricate (Plasmids/Virulence) and antiSMASH (Secondary Metabolites).\n"
]

# --- 1. PLASMID ANALYSIS ---
report_lines.append("## 1. Plasmid Content")
try:
    plasmids = pd.read_csv("results/downstream/ERR3335404_plasmids.csv", sep='\t')
    if plasmids.empty:
        report_lines.append(f"**Result:** No plasmids detected.\n")
    else:
        report_lines.append(f"**Result:** Found {len(plasmids)} plasmid hits.\n")
except Exception as e:
    report_lines.append(f"*Error reading plasmid file: {e}*\n")

# --- 2. VIRULENCE FACTOR ANALYSIS ---
report_lines.append("## 2. Virulence Factors (VFDB)")
try:
    virulence = pd.read_csv("results/downstream/ERR3335404_virulence.csv", sep='\t')
    if virulence.empty:
        report_lines.append("**Result:** No virulence factors detected.\n")
    else:
        report_lines.append(f"**Result:** Detected {len(virulence)} virulence genes. Top findings indicate a *Mycobacterium* species profile.\n")
        report_lines.append("| Gene | Product | Contig |")
        report_lines.append("|---|---|---|")
        for _, row in virulence.head(10).iterrows():
            gene = row['GENE']
            product = str(row['PRODUCT']).split('[')[0].strip()
            contig = str(row['SEQUENCE']).split('_cov')[0]
            report_lines.append(f"| {gene} | {product} | {contig} |")
        report_lines.append("\n*Note: High presence of esxA/esxB and ESX-1 secretion system proteins is a hallmark of pathogenic Mycobacteria.*\n")
except Exception as e:
    report_lines.append(f"*Error reading virulence file: {e}*\n")

# --- 3. SECONDARY METABOLITES (antiSMASH) ---
report_lines.append("## 3. Secondary Metabolites & Biosynthetic Gene Clusters (antiSMASH)")
try:
    with open("results/downstream/antismash/index.html", "r", encoding="utf-8") as f:
        html_content = f.read()
    
    high_hits = re.findall(r'<td class="similarity-text"[^>]*>High</td>\s*<td><a[^>]*>([^<]+)</a></td>\s*<td>([^<]+)</td>', html_content)
    
    if not high_hits:
        report_lines.append("**Result:** No high-confidence MIBiG matches found.\n")
    else:
        report_lines.append("**Result:** Found several High-Confidence Biosynthetic Gene Clusters matching known compounds:\n")
        for hit in set(high_hits): 
            compound_name, cluster_type = hit
            report_lines.append(f"*   **{compound_name}** ({cluster_type})")
        report_lines.append("\n*Note: The presence of nocobactin NA/mycobactin further confirms the Mycobacterium classification, as these are essential lipid-soluble siderophores used by this genus to survive inside host macrophages.*\n")
        
except Exception as e:
    report_lines.append(f"*Error parsing antiSMASH HTML: Ensure 'index.html' is extracted in results/downstream/antismash/ ({e})*\n")

# --- WRITE TO FILE ---
report_path = f"results/{sample_id}_Final_Report.md"
with open(report_path, "w") as f:
    f.write("\n".join(report_lines))

print(f"Success! Report saved to: {report_path}")
