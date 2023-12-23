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
"""Compile data for cluster of interst"""


import argparse
from this import d
import pandas as pd

from pathlib import Path

from bioservices import UniProt
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from tqdm import tqdm


def main():
    parser = build_parser()
    args = parser.parse_args()

    # get list of uniref protein seqs not in the original cluster
    uniref_seqs = get_uniref_seqs(args)

    # load seqs in original cluster
    all_seqs = []
    for record in SeqIO.parse(args.cluster_fasta,"fasta"):
        all_seqs.append(SeqRecord(Seq(record.seq), id=record.id)) 

    # combine all seqs into a single list and write out a multiseq fasta file
    all_seqs += uniref_seqs

    SeqIO.write(all_seqs, args.all_output, 'fasta')


def get_uniref_seqs(args):
    """Retrieve protein seqs for proteins in UniRef cluster that aren't in the original cluster"""

    cluster_df = pd.read_csv(args.cluster_csv)
    existing_uniprot_proteins = [_ for _ in cluster_df["UniProt_Accession"] if _ is not None]

    with open(args.uniprot_list, "r") as fh:
        uniprot_ids = fh.read().splitlines()

    sequences = {}

    for uniprot_id in tqdm(uniprot_ids, desc="Getting seqs from UniProt"):
        if uniprot_id in existing_uniprot_proteins:
            continue
        seq = UniProt().get_fasta_sequence(name)

        sequences[name] = seq
    
    seq_records = []
    for name in sequences:
        seq_records.append(SeqRecord(seq=Seq(sequences[name]), id=name))
    
    SeqIO.write(seq_records, args.uniref_output, 'fasta')

    return seq_records


def build_parser():
    """Build cmd-line args parser"""

    # Create parser object
    parser = argparse.ArgumentParser(
        prog="get_uniprot_seqs.py",
        description="Automate retrieving seqs from UniProt",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    # Add positional arguments to parser

    # Add path to input files
    parser.add_argument(
        "cluster_csv",
        type=Path,
        help="Path to the original cluster data csv file",
    )
    parser.add_argument(
        "cluster_fasta",
        type=Path,
        help="Path to the original cluster multiseq FASTA file",
    )
    parser.add_argument(
        "uniprot_list",
        type=Path,
        help="Path to file containing a list of UniProt Entry names",
    )
    # path to output files
    parser.add_argument(
        "all_output",
        type=Path,
        help="Path to fasta file of original cluster and uniref seqs",
    )
    parser.add_argument(
        "uniref_output",
        type=Path,
        help="Path to fasta file of uniref seqs",
    )

    return parser


if __name__ == "__main__":
    main()

