#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# (c) University of St Andrews 2022
# (c) University of Strathclyde 2022
# (c) James Hutton Institute 2022
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
"""Identify the cluster of UniProt seqs that contains the protein of interest"""


import argparse
import pandas as pd
import sys

from pathlib import Path

from bioservices import UniProt
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from tqdm import tqdm


def main():
    parser = build_parser()
    args = parser.parse_args()

    # load all protein seqs into memory
    all_sequences = {}
    for record in SeqIO.parse(args.all_seqs,"fasta"):
        all_sequences[record.id] = record.seq

    # organise clusters into a dict
    cluster_dict = parse_mmseq(args.mmseqs_output)

    cluster_of_interest = None
    for cluster in cluster_dict:
        if args.protein_of_interest in cluster_dict[cluster]:
            cluster_of_interest = cluster
            cluster_members = cluster_dict[cluster]
    
    if cluster_of_interest is None:
        print("CLUSTER OF INTERST NOT FOUND. Trying again using startswith match")
        for cluster in cluster_dict:
            for member in cluster_dict[cluster]:
                if member.split("_")[0] == args.protein_of_interest:
                    cluster_of_interest = cluster
                    cluster_members = cluster_dict[cluster]

    if cluster_of_interest is None:
        print("CLUSTER OF INTERST NOT FOUND")
        sys.exit(1)
    
    print(f"Cluster of interest: {cluster_of_interest}")

    cluster_seqs = []
    for member in cluster_members:
        cluster_seqs.append(SeqRecord(seq=Seq(all_sequences[member]), id=member))

    fasta_output = args.output_dir / "cluster_of_interest.fasta"
    members_list = args.output_dir / "cluster_of_interest_accessions.fasta"

    SeqIO.write(cluster_seqs, fasta_output, 'fasta')

    with open(members_list, "w") as fh:
        for member in cluster_members:
            fh.write(f"{member}\n")


def parse_mmseq(mmseq_tsv):
    """Parse mmseq output into a dict.
    
    :param mmseq_output: pandas df containing mmseq output
    
    Return dict"""
    mmseq_output = pd.read_table(mmseq_tsv)

    clusters = {}

    index = 0
    for index in tqdm(range(len(mmseq_output)), desc="Parsing MMseq tsv file"):
        row = mmseq_output.iloc[index]

        cluster_acc = row[0]
        member_acc = row[1]

        try:
            clusters[cluster_acc].add(member_acc)
        except KeyError:
            clusters[cluster_acc] = {member_acc}
    
    # check if the genbank accession used for the cluster name is in the cluster members
    # if not add it

    for cluster in clusters:
        if cluster not in clusters[cluster]:
            clusters[cluster_acc].add(cluster)

    return clusters


def build_parser():
    """Build cmd-line args parser"""

    # Create parser object
    parser = argparse.ArgumentParser(
        prog="get_uniprot_cluster_of_interest.py",
        description="Automate retrieving seqs from UniProt",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    # Add positional arguments to parser

    # Add path to input files
    parser.add_argument(
        "protein_of_interest",
        type=str,
        help="UniProt accession of the protein of interest",
    )
    parser.add_argument(
        "output_dir",
        type=Path,
        help="Path to the parent output file",
    )
    parser.add_argument(
        "all_seqs",
        type=Path,
        help="Path fasta file containing all protein seqs",
    )
    parser.add_argument(
        "mmseqs_output",
        type=Path,
        help="Path to mmseqs tsv file",
    )

    return parser


if __name__ == "__main__":
    main()

