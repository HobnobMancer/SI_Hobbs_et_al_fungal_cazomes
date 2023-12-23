#!/usr/bin/env bash
#

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

# build_cluster_tree.sh

# Use raxml-ng to build a tree

# $1 fasta file of aligned nucleotide seqs
# $2 output dir
# $3 model to use

mkdir $2

echo "------------------CHECK------------------"
raxml-ng --check \
  --msa $1 \
  --model $3 \
  --prefix $2/01_check

echo "------------------PARSE------------------"
raxml-ng --parse \
  --msa $1 \
  --model $3 \
  --prefix $2/02_parse

echo "------------------BUILD------------------"
raxml-ng \
  --msa $1 \
  --model $3 \
  --threads 3 \
  --seed 38745 \
  --prefix $2/03_infer

echo "------------------BOOTSTRAP------------------"
raxml-ng --bootstrap \
  --msa $1 \
  --model $3 \
  --threads 3 \
  --seed 38745 \
  --bs-trees 100 \
  --prefix $2/04_bootstrap
