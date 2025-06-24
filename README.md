# glnexus-whatshap

This performs **phasing of Glnexus joint-called VCF files** using WhatsHap. It includes the following steps:

## 🔧 Pipeline Overview

1. **Split** the Glnexus joint VCF into per-sample VCF files  
2. **Phase** each per-sample VCF using WhatsHap and its corresponding BAM file  
3. **Merge** all phased VCFs into a final joint-phased VCF

---

## 🧪 Requirements

- `bcftools`
- `htslib`
- `whatshap` (Python ≥ 3.7)
- `samtools`
- `GNU parallel`
  
---

## 📁 Folder Structure
├── split-glnexus-jointcalls.pbs # Splits joint VCF into per-sample VCFs
├── run-whatshapp-for-glnexus-splits-gpu.pbs.sh # Submits PBS jobs to phase each sample
├── merge-phased-glnexus.pbs # Merges all phased VCFs into one
├── list_files/
│ └── merged_bam_file_list_indo.txt # List of BAM files (one per sample, ends with .bai or .bam)

---

## 🚀 Usage

### Step 1: Split joint VCF by sample
qsub split-glnexus-jointcalls.pbs

### Step 2: Run whatshapp
bash run-whatshapp-for-glnexus-splits-gpu.pbs.sh 1 10

### Step 3: Merge phased VCF files
qsub merge-phased-glnexus.pbs
