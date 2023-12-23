#!/usr/bin/env bash

# (c) University of St Andrews 2020-2021
# (c) University of Strathclyde 2020-2021
# (c) James Hutton Institute 2020-2021
#
# Author:
# Emma E. M. Hobbs
#
# Contact
# eemh1@st-andrews.ac.uk
#
# Emma E. M. Hobbs,
# Biomolecular Sciences Building,
# University of St Andrews,
# North Haugh Campus,
# St Andrews,
# KY16 9ST
# Scotland,
# UK
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# expand_cluster.sh
#
# Retrieve protein seqs from UniProt, add to original cluster pool
# Cluster the new protein pool and for each cluster containing a protein of interst
# generate a nucleotide seq alignment and gene tree

# $1 path to text file listing the proteins of interest (identified by GenBank accession) in the original cluster
# $2 path to text file listing the uniprot accessions (from uniref or result of BLAST against uniprot)
# $3 output directory

# $4 path to original cluster data csv file
# $5 path to the original clusters multiseq FASTA file of protein seqs

# build output dir
mkdir -p $3

EXPANDED_PROTEIN_POOL="$3/expanded_protein_pool.fasta"
UNIPROT_SEQS="$3/uniprot_seqs.fasta"

python3 cluster_analysis/expand_cluster/get_uniprot_seqs \
    $4 \
    $5 \
    $2 \
    $EXPANDED_PROTEIN_POOL \
    $UNIPROT_SEQS

echo "-----Retrieved protein seqs from UniProt-----"

MMSEQ_DB = "$3/mmseq_db"
MMSEQ_OUT = "$3/mmseq_out"
MMSEQ_TSV = "$3/mmseq_output.tsv"
MMSEQ_TEMP = "$3/mmseq_temp"

bash cluster_analysis/expand_cluster/cluster_proteins.sh \
    $EXPANDED_PROTEIN_POOL \
    $MMSEQ_DB \
    $MMSEQ_OUT \
    $MMSEQ_TSV \
    0.7 \
    $MMSEQ_TEMP 


echo "-----Clustered expanded protein pool-----"

# identify clusters of interst, for each, get cluster data and generate a gene tree

PROTEINS_OF_INTERST=$(cat $1)

for PROTEIN in $PROTEINS_OF_INTERST
do

done
