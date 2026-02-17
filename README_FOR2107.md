# ENIGMA BD PRS project in FOR2107 Marburg and Muenster cohorts

This Readme is an internal documentation of the genetic data processing and 
analysis of the two FOR2107 cohorts (Marburg and Muenster) for the ENIGMA BD PRS
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
The cohort-specific project files, i.e. leave-one-out GWAS summary statistics,
for FOR2107 Marburg and Münster were downloaded and unzipped into the folders
`sumstats_Marburg` and `sumstats_Munster`.


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


