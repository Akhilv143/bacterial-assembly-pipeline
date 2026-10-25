import re
import matplotlib.pyplot as plt
from collections import Counter

print("Extracting BGC classes from antiSMASH HTML...")
html_file = "results/downstream/antismash/index.html"

try:
    with open(html_file, "r", encoding="utf-8") as f:
        content = f.read()
        
    # Regex to find the BGC class buttons in the antiSMASH HTML
    matches = re.findall(r'<div class="regbutton ([^ ]+) [^"]+ r\d+c\d+">', content)
    
    if not matches:
        print("Could not parse HTML. Ensure it is extracted correctly.")
    else:
        # Count the occurrences of each class (NRPS, PKS, Terpene, RiPP, hybrid, etc.)
        bgc_counts = Counter(matches)
        labels = list(bgc_counts.keys())
        sizes = list(bgc_counts.values())
        
        # Professional color palette
        colors = ['#2A9D8F', '#E9C46A', '#F4A261', '#E63946', '#264653', '#8AB17D', '#B5838D']
        
        print("Generating BGC Donut Chart...")
        fig, ax = plt.subplots(figsize=(8, 8))
        
        # Create donut chart
        wedges, texts, autotexts = ax.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=140, 
                                          colors=colors[:len(labels)], wedgeprops=dict(width=0.4, edgecolor='black'))
        
        plt.setp(autotexts, size=11, weight="bold", color="black")
        plt.setp(texts, size=12, weight="bold")
        
        ax.set_title("Biosynthetic Gene Cluster (BGC) Classifications", size=16, weight="bold", pad=20)
        
        output_path = 'results/downstream/bgc_classification_600dpi.png'
        plt.savefig(output_path, dpi=600, transparent=False, facecolor='white')
        print(f"Success! Plot saved to: {output_path}")

except Exception as e:
    print(f"Error: {e}")
