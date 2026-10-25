#!/bin/bash

# Define paths
SAMPLE="ERR3335404"
CONTIGS="results/spades/${SAMPLE}/contigs.fasta"
OUTDIR="results/downstream"
REFERENCE="data/Ecoli_reference.fna"

# Create output directory
mkdir -p ${OUTDIR}

echo "======================================================"
echo "    Starting Downstream Analysis for ${SAMPLE}        "
echo "======================================================"

# 1. Virulence Factor Screening (Using Abricate)
echo "[1/3] Screening for Virulence Factors (VFDB)..."
abricate --db vfdb --threads 8 ${CONTIGS} > ${OUTDIR}/${SAMPLE}_virulence.csv
echo "      Done! Saved to ${OUTDIR}/${SAMPLE}_virulence.csv"

# 2. Plasmid Identification (Using Abricate)
echo "[2/3] Identifying Plasmids (PlasmidFinder)..."
abricate --db plasmidfinder --threads 8 ${CONTIGS} > ${OUTDIR}/${SAMPLE}_plasmids.csv
echo "      Done! Saved to ${OUTDIR}/${SAMPLE}_plasmids.csv"

# 3. Species Confirmation (Using FastANI)
# FastANI calculates the Average Nucleotide Identity (>95% usually means same species)
echo "[3/3] Calculating Average Nucleotide Identity (FastANI)..."
if [ -f "${REFERENCE}" ]; then
    fastani -q ${CONTIGS} -r ${REFERENCE} -o ${OUTDIR}/${SAMPLE}_fastani.txt
    
    # Display the result directly in the terminal
    ANI_SCORE=$(awk '{print $3}' ${OUTDIR}/${SAMPLE}_fastani.txt)
    echo "      Done! FastANI Score vs Reference: ${ANI_SCORE}%"
else
    echo "      Warning: Reference genome not found at ${REFERENCE}. Skipping FastANI."
fi

echo "======================================================"
echo " Downstream Analysis Complete!                        "
echo " You can safely run antiSMASH on the WEB SERVER now.  "
echo "======================================================"
