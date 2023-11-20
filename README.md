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

To repeat the analysis and use the provided bash scripts, download the dbCAN database files into a directory called `dbcan/`, which is located in the root of the repository.

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

## Annotate CAZymes 

### Predict CAZymes using dbCAN

`pyrewton` supports using the CAZyme classifiers CUPP, dbCAN and eCAMI. For this analysis, dbCAN version 2.0.11 was used (see installation instructions in README). dbCAN can be configured using the `pyrewton` subcommand `run_dbcan`.

To repeat this analysis run the following command from the root of this directory, presuming dbCAN was installed to the directory called dbCAN.
```bash
scripts/cazymes/run_dbcan.sh
```

The output from dbCAN was written to `data/proteins/dbcan_output`. One output subdirectory was created per multi-sequence FASTA file parsed by dbCAN, and was named with the corresponding NCBI genomic version accession.

> Zhang H, Yohe T, Huang L, Entwistle S, Wu P, Yang Z, Busk PK, Xu Y, Yin Y. dbCAN2: a meta server for automated carbohydrate-active enzyme annotation. Nucleic Acids Res. 2018 Jul 2;46(W1):W95-W101. doi: 10.1093/nar/gky418. PMID: 29771380; PMCID: PMC6031026.

### Build a local CAZyme database

Build a local CAZyme database and populate it with all CAZyme records from the CAZy database (www.cazy.org) using the Python tool `cazy_webscraper`.

```bash
# for cazy_webscraper version 1
scripts/cazomes/build_cazy_db_1.sh

# for cazy_webscraper version 2
# email address is a requirement of entrez
scripts/cazomes/build_cazy_db_2.sh <email>
```

This analysis used `cazy_webscaper` version 1. However, since the update of the CAZy database in 2022, `cazy_webscraper` version 1 has become depracted. Therefore, in order to reproduce this analysis, `cazy_webscaper` version 2.2 or higher must be used.

The local CAZyme database created by `cazy_webscraper` version 1 is available as a TAR file in `data/cazy/cazy_download_2022_01_13.tar`.

> Hobbs EEM, Gloster TM, Pritchard L. cazy_webscraper: local compilation and interrogation of comprehensive CAZyme datasets. Microb Genom. 2023 Aug;9(8):mgen001086. doi: 10.1099/mgen.0.001086. PMID: 37578822; PMCID: PMC10483417.

### Build a local CAZome database

The script `build_cazome_db.sh` was used to coordinate `pyrewton` to parse the output from the dbCAN into a local SQLite3 database, along with taxonomic and genomic data from the CSV file created when downloading genomes, and also populated with CAZyme family annotations imported from the local CAZyme database.

The script uses the YAML file `data/cazomes/compile_db_config.yaml` as the input configuration file, lising the version of dbCAN used and the path to the output directory created when running dbCAN.

```bash
scripts/cazomes/compile_cazome_db.sh
```

## ANI tree reconstruction

## Phylogenetic tree reconstruction

### Oomycete

### Fungi

## Exploring CAZomes using `cazomevolve`

## Screening for positive selection
