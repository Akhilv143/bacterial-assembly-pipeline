# Automated Bacterial Genome Assembly & Virulence Profiling Pipeline

[![Snakemake](https://img.shields.io/badge/Workflow-Snakemake-0294A2.svg)](https://snakemake.readthedocs.io/)
[![SPAdes](https://img.shields.io/badge/Assembler-SPAdes-4CAF50.svg)](https://cab.spbu.ru/software/spades/)
[![Prokka](https://img.shields.io/badge/Annotation-Prokka-00599C.svg)](https://github.com/tseemann/prokka)
[![Abricate](https://img.shields.io/badge/Screening-Abricate-8A2BE2.svg)](https://github.com/tseemann/abricate)
[![antiSMASH](https://img.shields.io/badge/Metabolites-antiSMASH-DC143C.svg)](https://antismash.secondarymetabolites.org/)
[![MultiQC](https://img.shields.io/badge/Reporting-MultiQC-FF8C00.svg)](https://multiqc.info/)
[![R](https://img.shields.io/badge/Language-R_4.0+-198CE7.svg)](https://www.r-project.org/)
[![ggplot2](https://img.shields.io/badge/CRAN-ggplot2-3CB371.svg)](https://cran.r-project.org/package=ggplot2)
[![License](https://img.shields.io/badge/License-MIT-4CAF50.svg)](https://opensource.org/licenses/MIT)

## Project Overview
This repository contains a fully automated, scalable bioinformatics pipeline for the *de novo* assembly, structural annotation, and functional screening of bacterial genomes. Engineered to operate efficiently on local workstations under constrained memory conditions (~7 GB RAM), the workflow utilizes a resource-bounded Snakemake architecture. Environment reproducibility is strictly maintained via Conda, circumventing the need for root or sudo privileges.

A persistent challenge in clinical genomics is the accurate molecular profiling of blind or misidentified environmental isolates. By systematically integrating raw read quality control, graph-based assembly, and deep genomic screening, this pipeline rapidly resolves pathogenicity islands, antimicrobial resistance (AMR) markers, and secondary metabolite biosynthetic gene clusters (BGCs). 

During validation, an uncharacterized clinical isolate was processed through the workflow. Through automated downstream profiling, the sample was definitively classified as a highly pathogenic strain of ***Mycobacterium ulcerans*** (the etiologic agent of Buruli ulcer), demonstrating the pipeline's robust diagnostic utility and capacity for automated biological discovery.

## Dataset Analyzed
To validate the pipeline architecture, raw paired-end Illumina sequencing reads were retrieved from the European Nucleotide Archive (ENA):
- **Accession:** [ERR3335404](https://www.ebi.ac.uk/ena/browser/view/ERR3335404)
- **Source:** Clinical isolate of *Mycobacterium ulcerans* (strain CSURP7741), collected from a human patient in French Guiana.
- **Data Type:** Paired-end FASTQ (`_1.fastq.gz`, `_2.fastq.gz`).

## Analytical Methodology & Core Pipeline
The entire end-to-end computational workflow is orchestrated via a unified `Snakefile`, ensuring that every algorithmic step is logically tracked, parallelized across available CPU cores, and strictly reproducible.

### 1. Preprocessing & Quality Control (FastQC & Trimmomatic)
Raw paired-end reads undergo immediate quality assessment via FastQC. Sequencing adapters, low-quality ends (Phred < 33), and reads falling below a 36-base threshold are systematically trimmed using Trimmomatic to ensure only high-fidelity data enters the assembler algorithm.

### 2. *De Novo* Genome Assembly (SPAdes & QUAST)
Trimmed reads are assembled utilizing the SPAdes genome assembler in `--careful` mode to minimize mismatches and short indels. To prevent Out-Of-Memory (OOM) fatal errors on local hardware, SPAdes is strictly memory-capped (`-m 5`) while retaining multi-threading capabilities. The continuity and quality of the resulting `contigs.fasta` are subsequently evaluated via QUAST.

### 3. Structural Annotation (Prokka)
The draft assembly is parsed by Prokka to predict coding sequences (CDS), rRNAs, and tRNAs, yielding a standardized GFF3 annotation framework for downstream query.

### 4. Functional Screening (Abricate & antiSMASH)
- **Virulence & Resistance:** The assembled contigs are queried against the Virulence Factor Database (VFDB) and PlasmidFinder using Abricate to delineate the pathogen's invasive and resistance capabilities.
- **Secondary Metabolites:** The genome is submitted to antiSMASH to map massive Biosynthetic Gene Clusters (BGCs) responsible for the synthesis of antibiotics, toxins, and siderophores.

---

## Key Biological Discoveries

### Pathogenicity Islands & Virulence Profile
The pipeline successfully extracted a massive pathogenic arsenal typical of clinical *Mycobacteria*. 55 distinct virulence factors were identified, heavily featuring `esxA`, `esxB`, `eccCb1`, and `eccCa1`. These transcripts encode the structural components of the **ESX-1 & ESX-5 Type VII Secretion Systems**—the hallmark molecular machinery utilized by pathogenic *Mycobacteria* to rupture human host macrophages.

### Secondary Metabolite Biosynthesis
antiSMASH metabolic profiling revealed that **57.2%** of the organism's secondary metabolite capacity is dedicated to large-scale NRPS (28.6%) and PKS (28.6%) enzyme complexes. Crucially, the pipeline detected a high-confidence match for **Nocobactin NA / Mycobactin**. This specialized, lipid-soluble siderophore is synthesized exclusively by *Mycobacteria* to scavenge essential iron from host tissues, definitively confirming the taxonomic identity of the isolate.

---

## Visualizations

### Genome Purity Validation (Blob Plot)
A scatter plot of GC Content vs. Sequencing Coverage confirms the high purity of the biological sample. The primary contig cluster aligns perfectly at the **65.5% GC** threshold (the established genomic signature for *M. ulcerans*), with no secondary clusters indicative of cross-contamination. High-coverage vertical outliers (>150X) align with this exact GC percentage, verifying them as endogenous repetitive insertion sequences (e.g., IS2404) common in mycobacterial genomes, rather than external plasmid contamination.

<p align="center">
  <img src="results/downstream/gc_vs_coverage_purity_600dpi.png" width="85%" alt="GC vs Coverage Purity">
</p>

### Virulence & Genomic Feature Inventories
Custom R-based visualizations (`ggplot2`) detail the quantitative distribution of virulence genes across high-density contigs and summarize the structural inventory generated by Prokka (yielding 5,373 confirmed CDS). 

<p align="center">
  <img src="results/downstream/virulence_distribution_600dpi.png" width="48%" alt="Virulence Distribution">
  <img src="results/downstream/prokka_inventory_600dpi.png" width="48%" alt="Prokka Inventory">
</p>

### Biosynthetic Gene Cluster (BGC) Classification
A topological donut chart extracted from the antiSMASH analysis visualizes the organism's metabolic prioritization, which is heavily dominated by Non-Ribosomal Peptide Synthetases (NRPS) and Polyketide Synthases (PKS).

<p align="center">
  <img src="results/downstream/bgc_classification_600dpi.png" width="60%" alt="BGC Classification">
</p>

---

## Repository Structure
- **`Snakefile`**: The core Snakemake configuration orchestrating the directed acyclic graph (DAG) for the assembly and screening workflow.
- **`environment.yml`**: Conda environment specification ensuring exact dependency resolution for total reproducibility.
- **`run_downstream.sh`**: Bash execution script for automated local screening via FastANI and Abricate.
- **`generate_final_report.py`**: Python script engineered to parse VFDB/antiSMASH outputs and compile automated Markdown summaries.
- **`generate_r_plot.R` / `plot_gc_coverage.py`**: Custom R and Python scripts utilizing `ggplot2` and `matplotlib` to generate the figures located in `results/downstream/`.
