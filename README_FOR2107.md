# ENIGMA BD PRS project in FOR2107 Marburg and Muenster cohorts

This Readme is an internal documentation of the genetic data processing and 
analysis of the two FOR2107 cohorts (Marburg and Münster) for the ENIGMA BD PRS
Project.


## Project Resources

**Project Instructions:** https://github.com/nadineparker/ENIGMA_BD_PRS  

**Project Files - general:** https://doi.org/10.6084/m9.figshare.25872160.v3  
**Project Files - cohort-specific:** https://doi.org/10.6084/m9.figshare.27804729  


## Preparations on Marvin HPC cluster

The git repo was forked to https://github.com/friedav/ENIGMA_BD_PRS and cloned
onto Marvin. A new branch `FOR2107` was created.
The general project files were downloaded from figshare. All scripts present in
both the figshare archive and the git repository had identical content, but file
permissions differed. To ignore data files not present in git repo, a 
corresponding .gitignore file was added.


## GWAS summary statistics

The cohort-specific project files, i.e. leave-one-out GWAS summary statistics,
for FOR2107 Marburg and Münster were downloaded and unzipped into the folders
`sumstats_Marburg` and `sumstats_Munster`.
The `sumstats_Marburg` folder contained sumstats where the string "nofor2107" in
the file name indicated that these were the proper LOO sumstats, while in the
`sumstats_Muenster` folder the substring "nobdtrs" indicated that these were 
meant for a different cohort.

Thus, `sumstats_Marburg` was renamed to `sumstats_FOR2107` and used for both the
Marburg and the Münster subsample.

Check of other site specific sumstats folders from figshare (in case of mixups):
- Stockholm.zip: noSWEDEN
- UMCU.zip:      noucl_nodutch
- Munster.zip:   nobdtrs
- Sydney.zip:    nobmau_noneuc
- Marburg.zip:   nofor2107

-> BD_TRS is a different cohort from Münster (main PI Bernhard Baune), which is
   also part of PGC BD; however, as confirmed by Udo Dannlowski, there is no
   systematic relation between BD_TRS and FOR2107 Münster


## Comparison of instructions to previous ENIGMA SCZ MRS project

Readme files of the two projects (both by Nadine Parker) were compared to 
identify synergistic effects (e.g. in terms of preparation of scripts and data)
between projects. 

Relevant differences:
- different project files to be downloaded
- different FOR1207 subsamples to be used (BD)
- additional environment variable for operating system in Singularity script
- additional shared output: cell-type based polygenic scores
- different selection of variables/covariates to be shared as additional info

-> possible to use insights / code chunk from several steps of the 
  ENIGMA_SCZ_MRS project


## FOR2107 Input data, lift over and further data preparations

ID lists and covariate files for FOR2107 Marburg and Münster samples, 
respectively, were prepared by Lea Teutenberg and provided as xlsx files
(`data_FOR2107/Covariates_MR.xlsx` and `data_FOR2107/Covariates_MS.xlsx`)

While the FOR2107 imputed genotype data (including chr 1-22) in genomic build 
GRCh37 had previously undergone liftover to GRCh38 for the related 
ENIGMA_SCZ_MRS project, this was not used due to an issue with one sample.
Briefly, when comparing the sex info from the FAM file with the sex info from
the covariate files, a mismatch for Proband 1064 was detected. This sample had
not been included in the ENIGMA_SCZ_MRS project, thus this mismatch was 
previously not noticed / not relevant. 
As the `FOR2107_all_geno_remove_final.checkedConsent` was based on QC and 
preprocessing by Till Andlauer, it would have taken some effort to trace back
whether this genotype sample actually corresponds to Proband 1064 and just had
incorrect sex info, or whether this corresponds to Proband 1065 (both were
genetic duplicates, but only 1065 was also a sex mismatch, given recent 
phenotypic sex information).
At the same time, the new FOR2107 genotype data freeze was readily available.
Given that the healthy control samples indicated in the covariate files also 
differ from the ones used in the ENIGMA_SCZ_MRS project (meaning they are not
super comparable anyway), the new genotype data freeze was used here (which 
still required liftover to GRCh38).

For the liftover using the Singularity container, all files needed to be within
the same filesystem. Thus, all paths in the Auto_LiftOver_Singularity.sh script
were confined to Marvin's lustre file system. Moreover, the imputed FOR2107
genotype data contained about 1500 variants with missing rsIDs (< 0.1%). As they
caused an error with the original liftover script, they were excluded via a 
small modification of the script.

```
# lift over of full FOR2107 sample
. Auto_LiftOver_Singularity.sh

# remove weird empty folder structure created by Singularity
rm -rf /home/fdavid_hpc/projects/ENIGMA_BD_PRS/fdavid_hpc
```

Subsequent to liftover, internal proband IDs were converted to ENIGMA IDs and
the file set was filtered for individuals included in the FOR2107 Marburg and
FOR2107 Münster ENIGMA samples, respectively.

```
# further FOR2107 Marburg and Münster data preparation
Rscript scripts/prep_FOR2107_geno_step1.R
. scripts/prep_FOR2107_geno_step2.sh
```

The following Plink file sets (subsequently used for analysis) resulted from 
these steps:  
`data_FOR2107/FOR2107_b38_lifted.ENIGMAIDs.Marburg.{bed,bim,fam}`    
`data_FOR2107/FOR2107_b38_lifted.ENIGMAIDs.Muenster.{bed,bim,fam}`  


## Performing the analysis

Analyses were performed using the provided Singularity container and scripts 
modified for the FOR2107 Marburg and FOR2107 Münster sample.
On the Marvin HPC cluster, singularity version 1.4.2-1.el9 was installed at 
/usr/bin/singularity.

These are the modified Singularity scripts for FOR2107 Marburg and Münster:  
- Singularity_RUN_ENIGMA_BD_PRS_FOR2107Marburg.sh  
- Singularity_RUN_ENIGMA_BD_PRS_FOR2107Muenster.sh   

The analysis was run by submitting the corresponding Slurm jobs:

```
sbatch BATCH_BD_PRS_FOR2107Marburg.job
sbatch BATCH_BD_PRS_FOR2107Muenster.job
```

Relevant outputs were created by the scripts at `output_FOR2107Marburg` and
`output_FOR2107Muenster`.


### Modifications to the analysis scripts

Within the FOR2107 Marburg sample, two samples were assigned to the East Asian
(EAS) superpopulation. This lead to an error at the step of repeated call rate
filtering, as for some reason both samples were removed. It does not seem to be 
too useful to have this n=2 batch anyway, the Marburg script was modified in a
way that the EAS part was omitted. 

*Side note: It is surprising that there were any samples assigned to non-EUR
superpopulation (2 EAS in FOR2107 Marburg, 1 EAS + 1 AMR in FOR2107 Münster) at
all, since genotyping QC included a KING ancestry analysis with subsequent 
removal of all non-EUR samples. Unclear whether ancestry estimation on (pruned) 
imputed genotype data, the liftover to GRCh38, any variant filtering steps or 
the version of reference data set has caused this. Going back to the FOR2107 
Genotype QC intermediate files, especially after filtering for genetic outliers,
demonstrated a rather homogeneous sample. 
-> Decided to leave this as is.*


## Sharing of outputs

Both the `output_FOR2107Marburg` and `output_FOR2107Muenster` folder were 
packaged together into `ENIGMA_BD_PRS.outputs_FOR2107.zip` and were shared via a
Sciebo link with Lea Teutenberg in Marburg on 27.02.2026.


## Clean-up of project directory

To reduce the storage footprint of this project, the following files/folders 
were deleted:

- `sumstats/` (not used for FOR2107 as LOO version was required, see above)
- `sumstats_Munster/` (contained unrelated LOO sumstats)
