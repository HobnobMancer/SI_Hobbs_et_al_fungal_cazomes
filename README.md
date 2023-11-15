# Supplementary information to the exploration of Fungal and Oomycete CAZomes

Supplementary information for the annotation of 634 fungal and oomycete CAZomes using the Python packages `pyrewton` and `cazomevolve`.

## Online supplementary

Owing to the size of the data sets used, the figures are consequently compressed in the final manuscript. This remote repository contains the original full size, high resolution figures.

Additionally, some analyses are only briefly mentioned in the manuscript. The full method and results of these analyses are stored in this repository.

## How to use this repository.

You can use this repository like a website, to browse and see how we performed the analysis, or you can download it to inspect, verify, reproduce and build on our analysis.

### Downloading this repository

You can use `git` to _clone_ this repository to your local hard drive:

```bash
git clone git@github.com:HobnobMancer/SI_Hobbs_et_al_fungal_cazomes.git
```

Or you can download it as a compressed `.zip` archive from [this link](https://github.com/HobnobMancer/SI_Hobbs_et_al_fungal_cazomes/archive/refs/heads/master.zip).

### If you have problems with this repository

Please raise an issue at the corresponding `GitHub` page:

* [Issues for this repository](https://github.com/HobnobMancer/SI_Hobbs_et_al_fungal_cazomes/issues)

## Repo structure 

????

# Setup

You can use this archive to browse, validate, reproduce, or build on the phylogenomics analysis for the Hobbs et al. (2023) manuscript.

We recommend creating a conda environment specific for this activity, for example using the commands:
```bash
conda create -n pyrewton python=3.9 -y
conda activate pyrewton
conda install --file requirements.txt -y -c bioconda -c conda-forge -c predector
```

### Pyani

To use `pyani` in this analysis, version 0.3+ must be installed. At the time of development, `pyani` v0.3+ must be installed from `source`, this can be done by using the bash script `install_pyani_v0-3x.sh` (run from the root of this repository):
```bash
scripts/download/install_pyani_v0-3x.sh
```

### dbCAN

The installation instructions for `dbCAN` v==2.0.11 can be found [here](https://github.com/linnabrown/run_dbcan/tree/fde6d7225441ef3d4cb29ea29e39cfdcc41d8b19) and were followed to install dbCAN for the analysis presented in the manuscript.

# Reproducing the analysis

## Download genomes

The `pyrewton` subcommand `download_genomes` was used to download the genomes for the set of candidate species listed in `data/species/2020_03_01_species_list`.

Run the following command from the root of this directory. To run this command a email address must be provide as this is a requirement of Entrez.
```bash
scripts/genomes/download_genomes.sh <email>
```

The CSV file created when using `pyrewton` to download the genomes, and which lists the downloaded genomes, is provided in `data/genomes/2020_05_31_genome_dataframe.csv`.

The genomes were downloaded in `.gbff` format and written to `data/genomes/genomes`.

## Extracting proteomes

The subcommand `extract_protein_seqs` from `pyrewton` was used to extract the protein sequences from the downloaded genomic assemblies. These were written to `data/proteins/proteomes`, creating one multi-sequences FASTA file per genome.
```bash
scripts/genomes/extract_protein_seqs.sh
```

## Annotation CAZomes

### Build a local CAZyme database

### Get CAZy annotated CAZymes

### Run dbCAN

## Building a local CAZome database

## ANI tree reconstruction

## Phylogenetic tree reconstruction

### Oomycete

### Fungi

## Exploring CAZomes using `cazomevolve`

## Screening for positive selection
