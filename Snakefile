# --- Configuration ---
SAMPLES = ["ERR3335404"]

# --- Target Rule ---
rule all:
    input:
        "results/multiqc/multiqc_report.html",
        expand("results/prokka/{sample}/{sample}.txt", sample=SAMPLES),
        expand("results/abricate/{sample}_amr.csv", sample=SAMPLES)

# --- 1. Quality Control on Raw Reads ---
rule fastqc_raw:
    input:
        r1="data/{sample}_1.fastq.gz",
        r2="data/{sample}_2.fastq.gz"
    output:
        html1="results/fastqc/raw/{sample}_1_fastqc.html",
        zip1="results/fastqc/raw/{sample}_1_fastqc.zip",
        html2="results/fastqc/raw/{sample}_2_fastqc.html",
        zip2="results/fastqc/raw/{sample}_2_fastqc.zip"
    params:
        outdir="results/fastqc/raw"
    shell:
        """
        mkdir -p {params.outdir}
        fastqc -o {params.outdir} {input.r1} {input.r2}
        """

# --- 2. Trimming Low Quality Bases & Adapters ---
rule trimmomatic:
    input:
        r1="data/{sample}_1.fastq.gz",
        r2="data/{sample}_2.fastq.gz"
    output:
        r1_paired="results/trimmed/{sample}_1_trimmed.fastq.gz",
        r1_unpaired="results/trimmed/{sample}_1_unpaired.fastq.gz",
        r2_paired="results/trimmed/{sample}_2_trimmed.fastq.gz",
        r2_unpaired="results/trimmed/{sample}_2_unpaired.fastq.gz"
    threads: 8
    shell:
        """
        trimmomatic PE -threads {threads} -phred33 \
        {input.r1} {input.r2} \
        {output.r1_paired} {output.r1_unpaired} \
        {output.r2_paired} {output.r2_unpaired} \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
        """

# --- 3. Quality Control on Trimmed Reads ---
rule fastqc_trimmed:
    input:
        r1="results/trimmed/{sample}_1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_2_trimmed.fastq.gz"
    output:
        html1="results/fastqc/trimmed/{sample}_1_trimmed_fastqc.html",
        zip1="results/fastqc/trimmed/{sample}_1_trimmed_fastqc.zip",
        html2="results/fastqc/trimmed/{sample}_2_trimmed_fastqc.html",
        zip2="results/fastqc/trimmed/{sample}_2_trimmed_fastqc.zip"
    params:
        outdir="results/fastqc/trimmed"
    shell:
        """
        mkdir -p {params.outdir}
        fastqc -o {params.outdir} {input.r1} {input.r2}
        """

# --- 4. Genome Assembly with SPAdes ---
rule spades:
    input:
        r1="results/trimmed/{sample}_1_trimmed.fastq.gz",
        r2="results/trimmed/{sample}_2_trimmed.fastq.gz"
    output:
        contigs="results/spades/{sample}/contigs.fasta"
    params:
        outdir="results/spades/{sample}"
    threads: 8
    shell:
        """
        spades.py --careful -1 {input.r1} -2 {input.r2} -o {params.outdir} -t {threads} -m 5
        """

# --- 5. Assembly Quality Assessment ---
rule quast:
    input:
        contigs="results/spades/{sample}/contigs.fasta"
    output:
        report="results/quast/{sample}/report.html"
    params:
        outdir="results/quast/{sample}"
    shell:
        """
        quast.py {input.contigs} -o {params.outdir}
        """

# --- 6. Genome Annotation with Prokka ---
rule prokka:
    input:
        contigs="results/spades/{sample}/contigs.fasta"
    output:
        gff="results/prokka/{sample}/{sample}.gff",
        txt="results/prokka/{sample}/{sample}.txt"
    params:
        outdir="results/prokka/{sample}",
        prefix="{sample}"
    threads: 8
    shell:
        """
        rm -rf {params.outdir}
        prokka --outdir {params.outdir} --prefix {params.prefix} --cpus {threads} {input.contigs}
        """

# --- 7. Antimicrobial Resistance (AMR) Screening ---
rule abricate:
    input:
        contigs="results/spades/{sample}/contigs.fasta"
    output:
        report="results/abricate/{sample}_amr.csv"
    threads: 4
    shell:
        """
        mkdir -p results/abricate
        abricate --threads {threads} {input.contigs} > {output.report}
        """

# --- 8. Aggregate All Reports ---
rule multiqc:
    input:
        raw_qc=expand("results/fastqc/raw/{sample}_1_fastqc.zip", sample=SAMPLES),
        trim_qc=expand("results/fastqc/trimmed/{sample}_1_trimmed_fastqc.zip", sample=SAMPLES),
        quast=expand("results/quast/{sample}/report.html", sample=SAMPLES),
        prokka=expand("results/prokka/{sample}/{sample}.txt", sample=SAMPLES)
    output:
        report="results/multiqc/multiqc_report.html"
    params:
        outdir="results/multiqc/"
    shell:
        """
        multiqc -f results/ -o {params.outdir}
        """
