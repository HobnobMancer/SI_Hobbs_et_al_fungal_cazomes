#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# (c) University of St Andrews 2022
# (c) University of Strathclyde 2022
# (c) James Hutton Institute 2022
# Author:
# Emma E. M. Hobbs

# Contact
# eemh1@st-andrews.ac.uk

# Emma E. M. Hobbs,
# Biomolecular Sciences Building,
# University of St Andrews,
# North Haugh Campus,
# St Andrews,
# KY16 9ST
# Scotland,
# UK

# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# count cazy annotations 

# identify number of proteins in the local CAZome database that are annoated in the CAZy database
DB="data/cazome/database/cazome_database.db"

sqlite3 $DB -header -csv "
SELECT COUNT(DISTINCT P.protein\_id), T.genus, T.species
FROM Domains AS D
INNER JOIN Proteins AS P ON D.protein\_id = P.protein\_id
INNER JOIN Assemblies AS A ON P.assembly\_id = A.assembly\_id
INNER JOIN Taxonomies AS T ON A.taxonomy\_id = T.taxonomy\_id
INNER JOIN Classifiers AS C ON D.classifier\_id = C.classifier\_id
WHERE D.classifier\_id = '5'
GROUP BY T.species
" > data/cazome/cazy_protein_count.csv
