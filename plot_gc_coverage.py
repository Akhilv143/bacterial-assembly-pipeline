import matplotlib.pyplot as plt
import numpy as np

print("Parsing FASTA file for GC content and Coverage...")
fasta_file = "results/spades/ERR3335404/contigs.fasta"

lengths, coverages, gcs = [], [], []
seq, cov, length = "", 0, 0

with open(fasta_file, "r") as f:
    for line in f:
        line = line.strip()
        if line.startswith(">"):
            if seq and length > 1000: # Only plot contigs larger than 1kb
                gc = (seq.count('G') + seq.count('C')) / len(seq) * 100
                gcs.append(gc)
                lengths.append(length)
                coverages.append(cov)
            
            # Parse SPAdes header: >NODE_1_length_88090_cov_8.516717
            parts = line.split("_")
            length = int(parts[3])
            cov = float(parts[5])
            seq = ""
        else:
            seq += line.upper()
            
    # Catch the last sequence
    if seq and length > 1000:
        gc = (seq.count('G') + seq.count('C')) / len(seq) * 100
        gcs.append(gc)
        lengths.append(length)
        coverages.append(cov)

print("Generating Purity Scatter Plot...")
plt.figure(figsize=(10, 6))

# Use scatter plot where the size of the dot represents the length of the contig
sizes = [l / 500 for l in lengths] 
plt.scatter(gcs, coverages, s=sizes, alpha=0.6, c='#264653', edgecolors='black', linewidth=0.5)

plt.title('Genome Purity Check (GC% vs. Coverage)', fontsize=16, fontweight='bold', pad=15)
plt.xlabel('GC Content (%)', fontsize=12, fontweight='bold')
plt.ylabel('Sequencing Coverage (X)', fontsize=12, fontweight='bold')
plt.grid(axis='both', linestyle='--', alpha=0.5)

# Add a vertical line at the expected M. ulcerans GC% (65.5%)
plt.axvline(x=65.5, color='#E63946', linestyle='--', linewidth=2, label='Expected M. ulcerans GC (65.5%)')
plt.legend(loc='upper right')

output_path = 'results/downstream/gc_vs_coverage_purity_600dpi.png'
plt.tight_layout()
plt.savefig(output_path, dpi=600)
print(f"Success! Plot saved to: {output_path}")
