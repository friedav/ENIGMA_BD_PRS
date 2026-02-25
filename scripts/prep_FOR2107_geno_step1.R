#!/usr/bin/env Rscript
# Prepare ID mapping file to update FID/IID to FOR2107 ENIGMA IDs and
# prepare keep files to filter full FOR2107 Plink fileset to Marburg and Münster
# samples relevant to this ENIGMA project

library(here)
library(tidyverse)
library(data.table)
library(readxl)

# genotype-phenotype ID mapping
idmap <- read_xlsx(here("data_FOR2107/FOR2107_DNA_Sample_20230213.xlsx")) %>% 
  filter(`Probenausschluss (v.a. Widerspruch Datennutzung)` == "FALSE") %>% 
  mutate(Proband = str_pad(Proband, 4, "left", "0"),
         IID_clean = tolower(KurzUSI) %>% str_extract("depsyumr[0-9]{5}"),
         
         # ENIGMA IDs = Proband ID + timepoint + "_for2107"
         ENIGMA_ID = paste0(Proband, "-1_for2107"))


# FAM file from Plink bfile set after liftover
file.fam <- paste0("liftover_tmp/FOR2107_2019_2022_merged.HRC_imputed.", 
                   "dbSNP_rsIDs.MAF0.01_R20.3_b38_lifted.fam")
fam <- fread(here(file.fam), data.table = FALSE, 
             col.names = c("FID", "IID", "PID", "MID", "sex", "pheno")) %>% 
  inner_join(idmap, by = c("IID" = "IID_clean"))


#### Sample ####

cov.mr <- read_xlsx(here("data_FOR2107/Covariates_MR.xlsx"))
cov.ms <- read_xlsx(here("data_FOR2107/Covariates_MS.xlsx"))
sample.all <- bind_rows(Marburg = cov.mr, Muenster = cov.ms, .id = "Site")

with(sample.all, table(Dx, SubjID %in% fam$Proband, Site, useNA = "ifany"))
#-> not all individuals in Covariate files provided by Lea are present in 
#   genotype data (but with new genotype data freeze more than with the one
#   used in the ENIGMA SCZ MRS project)

sample.geno <- inner_join(sample.all, fam, by = c("SubjID" = "Proband"))


#### Sex and phenotype info ####

# check if sex and phenotype info in FAM file is correct
with(sample.geno, table(sex, Sex))  # -> yes
with(sample.geno, table(pheno, Dx)) # -> yes


#### ENIGMA sample IDs ####

# make ID mapping table to use with Plink
select(sample.geno, FID, IID, ENIGMA_FID = ENIGMA_ID, ENIGMA_IID = ENIGMA_ID) %>% 
  fwrite(here("data_FOR2107/Sample_ENIGMA_BD_PRS_All.Plink_updateIDs.tsv"),
       sep = "\t", col.names = FALSE)


#### Subsamples of FOR2107 Marburg and FOR2107 Münster ####

# make Plink keep file for Marburg sample
filter(sample.geno, Site == "Marburg") %>% 
  select(ENIGMA_FID = ENIGMA_ID, ENIGMA_IID = ENIGMA_ID) %>% 
  fwrite(here("data_FOR2107/Sample_ENIGMA_BD_PRS_MR.keep"), 
         sep = "\t", col.names = FALSE)

# make Plink keep file for Münster sample
filter(sample.geno, Site == "Muenster") %>% 
  select(ENIGMA_FID = ENIGMA_ID, ENIGMA_IID = ENIGMA_ID) %>% 
  fwrite(here("data_FOR2107/Sample_ENIGMA_BD_PRS_MS.keep"), 
         sep = "\t", col.names = FALSE)

