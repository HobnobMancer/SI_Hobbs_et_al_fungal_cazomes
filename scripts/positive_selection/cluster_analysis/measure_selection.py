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
"""Run CodeML to parse all proteins in a cluster, to measure positive selection in each protein sequence"""


import argparse
import re
import pandas as pd
import numpy as np
import sys

from pathlib import Path

from Bio import SeqIO
from Bio.Phylo.PAML import codeml
from rpy2.robjects import packages as rpackages
from tqdm import tqdm

# import R stats package
rstats = rpackages.importr("stats")


SIGNIFICANCE_LEVEL = 0.05


def main():
    parser = build_parser()
    args = parser.parse_args()

    positive_selection = []  # list of proteins with significant result
    no_positive_selection = []  # chisquared was not statistically signficant
    rerun = []

    summary_data = []

    cluster_df = pd.read_csv(args.cluster_df_path)

    cluster_accs = cluster_df["GenBank_Accession"]

    parent_output_dir = args.cluster_df_path.parent

    for accession in tqdm(cluster_accs, desc="Parse cluster proteins"):
        if type(accession) is float or accession is None:
            continue
        
        # make output directory for the current working protein
        output_dir = parent_output_dir / accession
        output_dir.mkdir(exist_ok=True)
        print("Made output dir:", output_dir)

        # bring protein of interest to top of MSA
        msa_path = reorder_msa(args.seq_path, output_dir, accession)

        print("Reordered MSA in phylip format:", msa_path)

        # label and write out tree
        tree_name = accession + '_tree'
        tree_path = output_dir / tree_name

        tree_labelled = label_tree(args.cluster_tree, accession, tree_path)
        print("Generated labelled tree:", tree_path)

        if tree_labelled is False:
            print("Could not generate tree for {}".format(accession))
            continue
            
        # compile control file for alternative model
        alt_model_cml, alt_output = prepare_codeml(
            output_dir,
            accession,
            msa_path,
            tree_path,
            args,
            alt=True,
        )

        print("Running alt model")

        alt_results = alt_model_cml.run(verbose=args.verbose)

        # compile control file for null model
        null_model_cml, null_output = prepare_codeml(
            output_dir,
            accession,
            msa_path,
            tree_path,
            args,
            null=True,
        )

        print("Running null model")
        
        null_results = null_model_cml.run(verbose=args.verbose)

        # calculate LRT, the degrees of freedom, and the p-value using chisquared
        p_value, lnl1, lnl0, np1, np0 = calculate_chisquared(alt_output, null_output)
        
        if p_value is None:
            print("Error occured when processing {}".format(accession))
            rerun.append(accession)
            continue

        if p_value <= SIGNIFICANCE_LEVEL:
            print("Positive selection detected:", p_value, accession)
            positive_selection.append("{}\t{}".format(accession, p_value))
        else:
            no_positive_selection.append("{}\t{}".format(accession, p_value))
            print("Positive selection NOT detected:", p_value, accession)

        summary_data.append([
            parent_output_dir,  # name of the cluster
            accession,
            p_value,
            lnl1,
            np1,
            lnl0,
            np0,
        ])

    with open((parent_output_dir/"positively_selected_proteins.out"), "w") as fh:
        for accession in positive_selection:
            fh.write("{}\n".format(accession))
    
    with open((parent_output_dir/"not_positively_selected_proteins.out"), "w") as fh:
        for accession in no_positive_selection:
            fh.write("{}\n".format(accession))

    with open((parent_output_dir/"rerun_proteins.out"), "w") as fh:
        for accession in rerun:
            fh.write("{}\n".format(accession))

    if args.summary_df is not None:  # add data to a summary df
        column_names = ["cluster", "accessions", "p_value", "lnl1", "np1", "lnl0", "np0"]

        new_data = pd.DataFrame(summary_data, columns=column_names)

        if args.summary_df.exists():  # add data to existing file
            summary_tsv = pd.read_csv(args.summary_df, sep="\t")
            
            # drop 'Unamed: 0' column
            summary_tsv = summary_tsv.drop(['Unnamed: 0'], axis=1)

            data = pd.concat([summary_tsv, new_data], ignore_index=True)

        else:
            data = pd.DataFrame(columns=column_names)

        data.to_csv(args.summary_df, sep="\t")


def reorder_msa(seq_path, output_dir, accession):
    """Make the seq for the given accession the first protein in the MSA
    
    :param seq_path: path to nucleotide MSA
    :param output_dir: path to output directory for the accession
    :param accession: str, GenBank accession of protein of interest
    
    Return path to reordered MSA
    """
    reordered_msa_path = output_dir / "{}_msa.fasta".format(accession)
    msa_path = output_dir / "{}_msa.phylip".format(accession)
    
    seqs = SeqIO.parse(seq_path, "fasta")
    
    seq_of_interest = None
    all_seqs = []

    for record in seqs:
        if record.id == accession.strip():
            seq_of_interest = record
        else:
            all_seqs.append(record)

    all_seqs.insert(0, seq_of_interest)

    SeqIO.write(all_seqs, reordered_msa_path, "fasta")

    fasta2phy(reordered_msa_path, msa_path)

    return msa_path


def fasta2phy(msa_input, phy_out):
    """Convert FASTA MSA to phylip format
    
    :param msa_input: path to MSA in fasta format
    :param phy_output: target path for phylip MSA file
    
    Return nothing
    """
    input_handle = open(msa_input, "r")
    output_handle = open(phy_out, "w")

    seqs = []
    headers = []

    alignments = SeqIO.parse(input_handle, "fasta")

    for a in alignments:
        headers.append(str(a.id))
        seqs.append(str(a.seq))

    input_handle.close()

    output_handle.write("  " + str(len(headers)) + "  " + str(len(seqs[0])) + "  " + "\n")

    for x in range(0, len(headers)):
        output_handle.write(headers[x] + "  " + seqs[x] + "\n")
    output_handle.close()


def label_tree(cluster_tree, accession, labelled_tree_path):
    """Label the forebranch in the tree and write to file

    :param cluster_tree: Path to file containing unlabelled gene tree
    :param accession: str, GenBank accession of the current working protein
    :param labelled_tree_path: path to write out labelled tree

    Return nothing
    """
    try:
        with open(cluster_tree, "r") as fh:
            unlabelled_tree = fh.read()

    except FileNotFoundError:
        print(
            "Could not load tree: cluster_tree\n"
            "Check the path is correct\n"
            "Terminating program"
        )
        sys.exit(1)

    if unlabelled_tree.find(accession) == -1:
        return False  # tree does not contain protein of interest

    labelled_tree = unlabelled_tree.replace(accession, "{} #1".format(accession))

    with open(labelled_tree_path, "w") as fh:
        fh.write(labelled_tree)
    
    return True


def prepare_codeml(output_dir, accession, msa_path, tree_path, args, alt=False, null=False):
    """Prepare CodeML for run
    
    :param output_dir: path to output dir
    :param accession: str, GenBank accession of protein of interest
    :param msa_path: Path to nucleotide MSA
    :param tree_path: path to tree file labelled with the protein of interest
    :param alt: bool, if true generate ctl file for alternative model
    :param null: bool, if true generate ctl file for null model
    
    Return CodeML class instance, and path to the output file
    """
    if alt:  # generate ctl for alternative model
        output_path = output_dir / "{}_alt_mdl_output".format(accession)
        fixed_omega = '0'
        model='alt'

    if null:  # generate ctl for null model
        output_path = output_dir / "{}_null_mdl_output".format(accession)
        fixed_omega = '1'
        model='null'

    print("{} output file: {}".format(model, output_path))

    cml = codeml.Codeml()

    cml.read_ctl_file(args.ctl_file)
    
    cml.alignment = str(msa_path)
    cml.tree = str(tree_path)
    cml.out_file = str(output_path)
    cml.working_dir = str(output_dir)
    cml.set_options(fix_omega=fixed_omega)
    cml.set_options(Small_Diff=0.45e-6)

    return cml, output_path


def calculate_chisquared(alt_model_output, null_model_output):
    """Calculate delta LRT and the degrees of freedom, and p-value
    
    :param alt_model_output: path to output file for alternative model
    :param null_model_output: path to output file for null model
    
    Return p-value (float), lnl1, lnl0, np1, np0
    """
    lnl1, lnl0, np1, np0 = None, None, None, None

    alt_results = codeml.read(alt_model_output)
    lnl1 = alt_results.get("NSsites").get(2).get('lnL')

    np1 = get_np(alt_model_output)

    if lnl1 is None or np1 is None:
        return None

    null_resuts = codeml.read(null_model_output)
    lnl0 = null_resuts.get("NSsites").get(2).get('lnL')

    np0 = get_np(null_model_output)
   
    if lnl0 is None or np0 is None:
        return None

    # calculate delta_LRT
    delta_lrt = 2*(lnl1 - lnl0)

    degrees_freedom = np1 - np0

    p_value = rstats.pchisq(delta_lrt, degrees_freedom)

    p_value = 1 - np.array(p_value)[0]

    return p_value, lnl1, lnl0, np1, np0


def get_np(output_file):
    """Get lnL and np values from CodeML output file
    
    :param output_file: path to output file
    
    Return float
    """
    with open(output_file, 'r') as fh:
        lines = fh.read().splitlines()
    
    np = None
    
    for line in lines:
        if line.startswith("lnL(ntime:"):
            # get np
            np = line.split(":")[2].strip()
            np = float(np.replace(")", ""))

            break  # found line of interest
    
    return np


def build_parser():
    """Build cmd-line args parser"""

    # Create parser object
    parser = argparse.ArgumentParser(
        prog="measure_selection.py",
        description="Automate running codeML for a cluster of proteins",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    # Add positional arguments to parser

    # Add path to input files
    parser.add_argument(
        "cluster_df_path",
        type=Path,
        help="Path to file containing protein data for cluster",
    )
    parser.add_argument(
        "cluster_tree",
        type=Path,
        help="Path unlabelled gene tree",
    )
    parser.add_argument(
        "seq_path",
        type=Path,
        help="Path to nucleotide MSA file",
    )
    parser.add_argument(
        "ctl_file",
        type=str,
        help="Path to nucleotide MSA file",
    )
    parser.add_argument(
        "--summary_df",
        type=Path,
        default=None,
        help="Path to write out summary df, or add data to an existing tsv file",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        dest="verbose",
        action="store_true",
        default=False,
        help="Print CodeML progress to terminal",
    )


    return parser


if __name__ == "__main__":
    main()
