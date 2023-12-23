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
"""Parse RaxML-ng output and get the best tree"""


import argparse
import re

from pathlib import Path


def main():
    parser = build_parser()
    args = parser.parse_args()

    best_tree_num = get_best_tree_num(args)

    best_tree = get_best_tree(best_tree_num, args)

    if best_tree is None:
        best_tree_num = retry_get_best_tree(args)

        best_tree = get_best_tree(best_tree_num, args)

    with open(args.tree_file, 'w') as fh:
        fh.write(best_tree)


def get_best_tree_num(args):
    """Get the number of the best tree
    
    :param args: cmd-line args parser
    
    Return str
    """
    with open(args.raxml_log, 'r') as fh:
        raxml_log = fh.read().splitlines()

    bootstrap_dict = {}  # #tree: logLikelihood

    for line in raxml_log:
        if line.find("] Bootstrap tree #") != -1:
            tree_number = line.split("#")[-1].split(",")[0].strip()
            loglikelihood = line.split("#")[-1].split(",")[-1].split(":")[-1].strip()
            bootstrap_dict[tree_number.strip()] = loglikelihood.strip()

    tree_ranks = []
    for tree, ml in sorted(bootstrap_dict.items(), key=lambda x: x[1], reverse=False):
        tree_ranks.append(tree)
    
    best_tree = tree_ranks[0]

    print("Best tree num: ", best_tree)

    return best_tree


def get_best_tree(best_tree_num, args):
    """Get the best tree
    
    :param best_tree_num: str, number of the best tree
    :param args: cmd-line args parser
    
    Return str of best tree in newick format
    """
    with open(args.boostraps_file, 'r') as fh:
        all_trees = fh.read().splitlines()

    tree_num = 1

    best_tree = None

    for tree in all_trees:
        if str(tree_num) == best_tree_num:
            best_tree = tree
            continue
        else:
            tree_num += 1

    return best_tree


def retry_get_best_tree(args):
    """Retry getting the best tree"""
    with open(args.raxml_log, 'r') as fh:
        raxml_log = fh.read().splitlines()

    bootstrap_dict = {}  # #tree: logLikelihood

    for line in raxml_log:
        if line.find("Bootstrap tree") != -1:
            if len(re.findall("Bootstrap tree", line)) > 1:
                # multiple bootstras in one line
                if len(re.findall("logLikelihood", line)) > 1:
                    separate_lines = line.split("worker")
                    for new_line in separate_lines:
                        if new_line.find("logLikelihood:") != -1:
                            if new_line.find("Bootstrap tree") != -1:
                                loglikelihood = new_line.split("-")
                                loglikelihood = "-" + loglikelihood[-1][:11]

                                tree_num = new_line.split("Bootstrap tree #")[1]
                                tree_num = tree_num.split(",")[0]

                                if loglikelihood.startswith("-"):
                                    bootstrap_dict[tree_num.strip()] = loglikelihood.strip()

                else:
                    loglikelihood = line.split("-")
                    loglikelihood = "-" + loglikelihood[-1][:11]

                    tree_num = line.split("Bootstrap tree #")[1]
                    tree_num = tree_num.split(",")[0]

                    if loglikelihood.startswith("-"):
                        bootstrap_dict[tree_num.strip()] = loglikelihood.strip()

    tree_ranks = []
    for tree, ml in sorted(bootstrap_dict.items(), key=lambda x: x[1], reverse=False):
        tree_ranks.append(tree)
    
    best_tree = tree_ranks[0]

    print("Best tree num: ", best_tree)

    return best_tree


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
        "raxml_log",
        type=Path,
        help="Path to RaxML-ng log file",
    )
    parser.add_argument(
        "boostraps_file",
        type=Path,
        help="Path to RaxML-ng bootstrap file",
    )
    parser.add_argument(
        "tree_file",
        type=Path,
        help="Path to output file",
    )

    return parser


if __name__ == "__main__":
    main()

