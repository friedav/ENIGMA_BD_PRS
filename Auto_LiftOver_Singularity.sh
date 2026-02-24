#!/bin/bash

############### Please Fill in the paths below

## Base Directory - this should be a parent directory that holds all project data
 # project data includes your genetic plink files + all downloaded files, software, and containers
export Base_Dir=/lustre/scratch/data

## Path to project directory with all downloaded files
export Project_Path=${Base_Dir}/fdavid_hpc-ENIGMA_BD_PRS

## Path to Your Samples PLINK Files
export Sample_Dir=${Project_Path}/data_FOR2107

## Plink Sample Prefix - the plink file prefix (filename before .bed, .fam, .bim suffix)
export Prefix=FOR2107_2019_2022_merged.HRC_imputed.dbSNP_rsIDs.MAF0.01_R20.3

## Path to liftover chain file
# we provide build hg19/GRCh37 to hg39/GRCh38 - however you can provide the location to an alternative file
export liftover_chain=${Project_Path}/scripts/hg19ToHg38.over.chain.gz

## number of available cores for processing
##if submitting a slurm job you can comment this out
export NCORES=2
export MEMORY=$((${NCORES} * 5800)) 	## orig = 4 cores with 7700 memory


##################################################################################
############### END - Do Not Make Changes Beyond This Point ######################
##################################################################################

OUT_DIR=${Project_Path}/liftover_tmp
mkdir -p ${OUT_DIR}

export liftover=${Project_Path}/scripts/liftOver

export plink2="singularity exec --home=$PWD:/home --bind ${Base_Dir} ${Project_Path}/ldpred2.sif plink2"
export plink1="singularity exec --home=$PWD:/home --bind ${Base_Dir} ${Project_Path}/ldpred2.sif plink"

# Make Non-Duplicated SNP ID Plink files
# (modification for FOR2107 data: exclude variants with missing rsIDs, as they
# cause an "Error: Duplicate ID '.'." in the last step)
echo "." > ${OUT_DIR}/exclude_vars_missing_rsID.txt
${plink2} --bfile ${Sample_Dir}/${Prefix} --rm-dup 'force-first' \
        --exclude ${OUT_DIR}/exclude_vars_missing_rsID.txt \
        --make-bed --out ${OUT_DIR}/${Prefix}_noDup --threads ${NCORES} --memory ${MEMORY}
rm ${OUT_DIR}/exclude_vars_missing_rsID.txt

# Ensure chromosomes are renamed properly for liftover (chr1, ..., chrM etc.).
bim_tmp="${OUT_DIR}/${Prefix}.lift.tmp"
${plink2} --bfile ${OUT_DIR}/${Prefix}_noDup --output-chr chrM \
    --make-just-bim --out ${bim_tmp} \
    --threads ${NCORES} --memory ${MEMORY}

# If PAR region is split in the batch_bfile, after applying '--output-chr chrM',
# SNPs in PAR will be on "chrXY".
# Liftover requires SNPs in PAR region to be on chrX, otherwise they will not be lifted corectly.
bed_orig="${OUT_DIR}/${Prefix}.liftover.orig.bed"
awk '{if($1=="chrXY") print("chrX",$4-1,$4,$2); else print($1,$4-1,$4,$2);}' \
    ${bim_tmp}.bim > ${bed_orig}
unlifted_snps="${OUT_DIR}/${Prefix}.unlifted_snps"

if [ -f "${liftover_chain}" ]; then
    echo "Lifting coordinates using ${liftover_chain}"
    bed_mapped="${OUT_DIR}/${Prefix}.liftover.mapped.bed"
    bed_unmapped="${OUT_DIR}/${Prefix}.liftover.unmapped.bed"
    ${liftover} ${bed_orig} ${liftover_chain} ${bed_mapped} ${bed_unmapped}
    grep -Pv "^#" ${bed_unmapped} | cut -f4 > ${unlifted_snps}
else
    echo "liftover_chain is not provided. Coordinates are not lifted."
    bed_mapped=${bed_orig}
    touch ${unlifted_snps} # Ensure that (empty) file exists.
fi

${plink1} --bfile ${OUT_DIR}/${Prefix}_noDup \
    --update-chr ${bed_mapped} 1 4 --update-map ${bed_mapped} 3 4 --exclude ${unlifted_snps} \
    --allow-extra-chr --make-bed --out ${OUT_DIR}/${Prefix}_b38_lifted \
    --threads ${NCORES} --memory ${MEMORY}

