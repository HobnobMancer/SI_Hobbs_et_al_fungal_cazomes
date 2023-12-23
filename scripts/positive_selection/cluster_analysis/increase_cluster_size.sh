#!/usr/bin/env bash
#
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

# increase_cluster_size.sh

# Retrieve records from UniProt with 50% identity to a protein of interst and cluster with 70% id

# $1 protein of interest
# $2 plain text file listing UniProt records
# $3 output directory
# $4 original cluster data csv file
# $5 original cluster multisequence fasta file

# mkdir -p $3

UNIPROT_SEQS="$3/uniref_cluster_seqs.fasta"

# python3 cluster_analysis/get_uniprot_seqs.py $2 $UNIPROT_SEQS

echo "Retrieved UniRef cluster seqs"

MMSEQS_DB="$3/mmseqs_uniref_db"
MMSEQS_OUTPUT="$3/mmseqs_output"
MMSEQS_TSV="$3/mmseqs_output_df.tsv"

# create a MMseq2 databasae (DB)
# mmseqs createdb $UNIPROT_SEQS $MMSEQS_DB

# run cluster
# mmseqs cluster $MMSEQS_DB $MMSEQS_OUTPUT tmp --min-seq-id 0.7 -c 0.7

# create tsv output 
# mmseqs createtsv $MMSEQS_DB $MMSEQS_DB $MMSEQS_OUTPUT $MMSEQS_TSV

echo "Clustered proteins"

#python3 cluster_analysis/get_uniprot_cluster_of_interest.py $1 $3 $UNIPROT_SEQS $MMSEQS_TSV

echo "Identified UniProt cluster of interest"

UNIPROT_CLUSTER_FASTA="$3/cluster_of_interest.fasta"
EXPANDED_CLUSTER_OUTPUT="$3/expanded_cluster"
python3 cluster_analysis/expand_cluster/gather_unique_seqs.py $4 $5 $UNIPROT_CLUSTER_FASTA $EXPANDED_CLUSTER_OUTPUT

echo "Done"
