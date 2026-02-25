#!/usr/bin/env bash
# Update IDs to FOR2107 ENIGMA IDs and filter to the FOR2107 Marburg and Münster
# analysis samples

BFILE=liftover_tmp/FOR2107_2019_2022_merged.HRC_imputed.dbSNP_rsIDs.MAF0.01_R20.3_b38_lifted
IDMAP=data_FOR2107/Sample_ENIGMA_BD_PRS_All.Plink_updateIDs.tsv
KEEPMR=data_FOR2107/Sample_ENIGMA_BD_PRS_MR.keep
KEEPMS=data_FOR2107/Sample_ENIGMA_BD_PRS_MS.keep

# shorten BFILE prefix of generated files
BFILESHORT=data_FOR2107/FOR2107_b38_lifted

# note: only IDs for the individuals included in the ENIGMA analysis samples are
# updated
#
# TODO check for liftover of new data freeze
# note on chr set filtering for 1-22: 
# - the FOR2107 bestguess input data had previously been filtered for chr 1-22,
#   so no X/Y variants would be expected; 1 chrX variant had been introduced by
#   liftover (7:130275820:G, not sure why), but this is best to be excluded
# - the liftover has also introduced 5 extra chromosomes (e.g. 
#   chr8_KI270821v1_alt) with a total of ~600 SNPs; these extra chromosomes 
#   caused an error in later plink commands of the 
#   Singularity_RUN_ENIGMA_SCZ_PRS.sh script within the previous ENIGMA SCZ MRS
#   project, thus they are also excluded
plink --bfile $BFILE \
      --update-ids $IDMAP \
      --allow-extra-chr --chr 1-22 \
      --make-bed --out ${BFILESHORT}.ENIGMAIDs

# make input Plink file set for Marburg sample
plink --bfile ${BFILESHORT}.ENIGMAIDs --allow-extra-chr \
      --keep $KEEPMR --make-bed --out ${BFILESHORT}.ENIGMAIDs.Marburg

# make input Plink file set for Münster sample
plink --bfile ${BFILESHORT}.ENIGMAIDs --allow-extra-chr \
      --keep $KEEPMS --make-bed --out ${BFILESHORT}.ENIGMAIDs.Muenster
 