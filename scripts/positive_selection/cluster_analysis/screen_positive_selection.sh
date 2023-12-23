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

# automate_cluster_analysis.sh

# $1 Path to text file listing the names of the clusters of interest
# $2 Path to dir containing clusters of interest
# $3 email address
# $4 Path to write out a summary tsv file
# $5 Str 'dbcan' or 'all' or 'cazy' FASTA file of protein seqs to use for clusters

#
# Get list of clusters of interest
#

echo "1: $1"
echo "2: $2"
echo "3: $3"
echo "4: $4"
echo "5: $5"

CLUSTERS=$(cat $1)

for CLUSTER in $CLUSTERS
do
    echo "--------Starting processing cluster $CLUSTER--------"

    CLUSTER_DIR="$2/$CLUSTER"  # dir containing cluster
    
    echo "Cluster dir: $CLUSTER_DIR"

    PROTEIN_SEQS="$CLUSTER_DIR/$CLUSTER-$5-seqs.fasta"  # file containing protein seqs

    echo "Protein seqs: $PROTEIN_SEQS"

    ALIGNED_PROTS="$CLUSTER_DIR/$CLUSTER-aligned_proteins.fasta"  # MSA of protein seqs

    echo "Protein alignment: $ALIGNED_PROTS"

    # align proteins

    mafft --thread 12 $PROTEIN_SEQS > $ALIGNED_PROTS 
    
    echo "---Aligned protein seqs---"

    # get CDSs using ncfp
    
    CDS_DIR="$CLUSTER_DIR/$CLUSTER-cds"  # outpuit dir for ncfp

    echo "Ncfp output dir: $CDS_DIR"
    
    ncfp \
        $PROTEIN_SEQS \
        $CDS_DIR \
        $3 \
        --use_protein_ids \
        --drop_stop_codons

    echo "---Retrieved CDSs---"

    # backthread cds onto aligned proteins using t-coffee

    NTS_FASTA="$CDS_DIR/ncfp_nt.fasta"

    echo "Nts FASTA: $NTS_FASTA"

    ALIGNED_NTS="$CLUSTER_DIR/$CLUSTER-aligned_nts.fasta"  # MSA of nucleotide seqs

    echo "Nt alignemnt: $ALIGNED_NTS"

    t_coffee -other_pg seq_reformat \
        -in $NTS_FASTA \
        -in2 $ALIGNED_PROTS \
        -action +thread_dna_on_prot_aln \
        -output fasta \
        > $ALIGNED_NTS

    echo "---Backthreaded cds onto aligned proteins---"

    # check backthread was ok
    if echo "$(cat $ALIGNED_NTS)" | grep -q -- "-M-"; then     echo "Incorrect backthread: $CLUSTER"; continue; fi

    # run modeltest to get the best model

    MODELTEST_OUT="$CLUSTER_DIR/modeltest_output"
    
    echo "modeltest output: $MODELTEST_OUT"

    modeltest-ng -i $ALIGNED_NTS -d nt -o $MODELTEST_OUT

    # get best model from modeltest output

    MODELTEST_LOG="$MODELTEST_OUT.out"
    BEST_MODEL_FILE="$CLUSTER_DIR/bestmodel.txt"

    python3 cluster_analysis/get_model.py \
        $MODELTEST_LOG \
        $BEST_MODEL_FILE
    
    BEST_MODEL=$(cat $BEST_MODEL_FILE)

    echo "Best model: $BEST_MODEL"

    # build tree using raxml-ng and bootstrap tree

    echo "---Building tree---"

    TREE_DIR="$CLUSTER_DIR/tree"

    mkdir $TREE_DIR
    
    echo "Tree dir: $TREE_DIR"

    echo "RaxML-ng Check"

    raxml-ng --check \
    --msa $ALIGNED_NTS \
    --model $BEST_MODEL \
    --prefix $TREE_DIR/01_check

    echo "RaxML-ng Parse"

    raxml-ng --parse \
    --msa $ALIGNED_NTS \
    --model $BEST_MODEL \
    --prefix $TREE_DIR/02_parse

    echo "RaxML-ng Build"

    raxml-ng \
    --msa $ALIGNED_NTS \
    --model $BEST_MODEL \
    --threads 3 \
    --seed 38745 \
    --prefix $TREE_DIR/03_infer

    echo "RaxML-ng Bootstrap"

    raxml-ng --bootstrap \
    --msa $ALIGNED_NTS \
    --model $BEST_MODEL \
    --threads 3 \
    --seed 38745 \
    --bs-trees 100 \
    --prefix $TREE_DIR/04_bootstrap

    # get best tree

    BEST_TREE_FILE="$CLUSTER_DIR/bestTree"

    python3 cluster_analysis/get_best_tree.py \
        $TREE_DIR/04_bootstrap.raxml.log \
        $TREE_DIR/04_bootstrap.raxml.bootstraps \
        $BEST_TREE_FILE

    BEST_TREE=$(cat $BEST_TREE_FILE)

    echo "Best tree file: $BEST_TREE_FILE"

    # run CodeML

    echo "Running CodeML: $ALIGNED_NTS"

    CLUSTER_CSV="$CLUSTER_DIR/$CLUSTER-cluster_data.csv"
    python3 scipts/positive_selection/cluster_analysis/measure_selection.py \
        $CLUSTER_CSV \
        $BEST_TREE_FILE \
        $ALIGNED_NTS \
        cluster_analysis/codeml_ctl.ctl \
        --summary_df $4

    # run hypy
    hyphy busted --alignment $ALIGNED_NTS --tree $BEST_TREE_FILE --output "$4-BUSTED"
    hyphy absrel --alignment $ALIGNED_NTS  --tree $BEST_TREE_FILE --output "$4-ABSREL"
    hyphy meme --alignment $ALIGNED_NTS  --tree $BEST_TREE_FILE --output "$4-MEME"


done
