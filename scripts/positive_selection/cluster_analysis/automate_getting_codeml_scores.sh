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
# $3 Path to write out a summary tsv file

#
# Get list of clusters of interest
#

echo "1: $1"
echo "2: $2"
echo "3: $3"

CLUSTERS=$(cat $1)

for CLUSTER in $CLUSTERS
do
    echo "--------Starting processing cluster $CLUSTER--------"

    CLUSTER_DIR="$2/$CLUSTER"  # dir containing cluster
    
    echo "Cluster dir: $CLUSTER_DIR"

    CLUSTER_CSV="$CLUSTER_DIR/$CLUSTER-cluster_data.csv"
    python3 cluster_analysis/get_codeml_results.py \
        $CLUSTER_CSV \
        --summary_df $3

done
