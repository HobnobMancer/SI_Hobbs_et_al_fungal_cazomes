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
"""Parse modeltest log file and get the best model"""


import argparse

from pathlib import Path


def main():
    parser = build_parser()
    args = parser.parse_args()

    with open(args.modeltest_log, "r") as fh:
        lines = fh.read().splitlines()

    lines_of_interst = []

    for line in lines:
        if line.find("> raxml-ng") != -1:
            lines_of_interst.append(line)

    freq_dict = {}

    for line in lines_of_interst:
        model = line.split("--model ")[1]

        try:
            freq_dict[model] += 1
        except KeyError:
            freq_dict[model] = 1
    
    models = []
    for model, count in sorted(freq_dict.items(), key=lambda x: x[1], reverse=True):
        models.append(model)

    with open(args.output, 'w') as fh:
        fh.write(models[0])


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
        "modeltest_log",
        type=Path,
        help="Path to modeltest log file",
    )
    parser.add_argument(
        "output",
        type=Path,
        help="Path to output file",
    )

    return parser


if __name__ == "__main__":
    main()

