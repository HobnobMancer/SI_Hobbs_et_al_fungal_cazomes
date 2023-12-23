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

# interrogate cazome

# get CSV for note book

DBPATH="data/cazome/protein_database.db"

# create csv file that will have family, genome and protein, as well as tax data and can be used
# as input to CAZomevolve

sqlite3 $DBPATH -header -csv "WITH famQ AS (
SELECT P.genbank_accession AS Fprotein, F.family AS FFamily, C.classifier AS FClassifier
FROM Proteins AS P
INNER JOIN Domains AS D on P.protein_id = D.protein_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
WHERE (D.classifier_id = 1) OR (D.classifier_id = 5)
),
TaxQ AS (
SELECT P.genbank_accession AS Tprotein, A.assembly_accession AS Assembly, T.genus AS Genus, T.species AS Species
FROM Proteins AS P
INNER JOIN Assemblies AS A ON P.assembly_id = A.assembly_id
INNER JOIN Taxonomies AS T ON A.taxonomy_id = T.taxonomy_id
)
SELECT famQ.FFamily AS Family, TaxQ.Assembly AS Genome, famQ.Fprotein AS Protein, TaxQ.Genus AS Genus, TaxQ.Species AS Species, famQ.FClassifier AS Classifier
FROM famQ
INNER JOIN TaxQ ON famQ.Fprotein = TaxQ.Tprotein" > "data/cazome/fam-genome-protein-genus-species.csv"

# get number of CAZymes from CAZy in db
sqlite3 -header -csv data/cazome/protein_database.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, T.genus, T.species
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN Assemblies AS A ON P.assembly_id = A.assembly_id     
INNER JOIN Taxonomies AS T ON A.taxonomy_id = T.taxonomy_id     
WHERE C.classifier = 'CAZy'
GROUP BY T.species
" > data/cazome/cazy-cazymes-in-cazome-db.csv

sqlite3 -header -csv data/cazome/protein_database.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, T.genus, T.species, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN Assemblies AS A ON P.assembly_id = A.assembly_id     
INNER JOIN Taxonomies AS T ON A.taxonomy_id = T.taxonomy_id     
GROUP BY T.species, C.classifier
ORDER BY T.genus, T.species
" > data/cazome/cazymes-in-cazome-db.csv


sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT G.genbank_accession) AS Num_CAZy_Prot_IDs, T.genus AS Genus, T.species AS Species
FROM Genbanks AS G
INNER JOIN Taxs AS T ON G.taxonomy_id = T.taxonomy_id     
WHERE (T.genus = 'Albugo' and T.species = 'candida') OR
(T.genus = 'Aspergillus' AND T.species = 'niger') OR
(T.genus = 'Aspergillus' AND T.species = 'sydowii') OR
(T.genus = 'Aspergillus' AND T.species = 'nidulans') OR
(T.genus = 'Aspergillus' AND T.species = 'fumigatus') OR
(T.genus = 'Fusarium' AND T.species = 'oxysporum') OR
(T.genus = 'Fusarium' AND T.species = 'graminearum') OR
(T.genus = 'Fusarium' AND T.species = 'proliferatum') OR
(T.genus = 'Hyaloperonospora' AND T.species = 'arabidopsidis') OR
(T.genus = 'Magnaporthe' AND T.species = 'grisea') OR
(T.genus = 'Magnaporthe' AND T.species = 'oryzae') OR
(T.genus = 'Mycosphaerella' AND T.species = 'graminicola') OR
(T.genus = 'Phytophthora' AND T.species = 'capsici') OR
(T.genus = 'Phytophthora' AND T.species = 'cinnamomi') OR
(T.genus = 'Phytophthora' AND T.species = 'infestans') OR
(T.genus = 'Phytophthora' AND T.species = 'parasitica') OR
(T.genus = 'Phytophthora' AND T.species = 'sojae') OR
(T.genus = 'Phytophthora' AND T.species = 'ramorum') OR
(T.genus = 'Plasmopara' AND T.species = 'halstedii') OR
(T.genus = 'Plasmopara' AND T.species = 'viticola') OR
(T.genus = 'Plasmopara' AND T.species = 'obducens') OR
(T.genus = 'Rhynchosporium' AND T.species = 'secalis') OR
(T.genus = 'Rhynchosporium' AND T.species = 'commune') OR
(T.genus = 'Rhynchosporium' AND T.species = 'agropyri') OR
(T.genus = 'Trichoderma' AND T.species = 'harzianum') OR
(T.genus = 'Trichoderma' AND T.species = 'reesei') OR
(T.genus = 'Trichoderma' AND T.species = 'citrinoviride') OR
(T.genus = 'Trichoderma' AND T.species = 'atroviride') OR
(T.genus = 'Trichoderma' AND T.species = 'asperellum') OR
(T.genus = 'Ustilago' AND T.species = 'maydis') OR
(T.genus = 'Ustilago' AND T.species = 'bromivora')
GROUP BY T.species
" > data/cazome/cazy-cazymes-in-cazy-db-exact-species-match.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT G.genbank_accession) AS Num_CAZy_Prot_IDs, T.genus AS Genus, T.species AS Species
FROM Genbanks AS G
INNER JOIN Taxs AS T ON G.taxonomy_id = T.taxonomy_id
WHERE (T.genus = 'Albugo' AND T.species LIKE 'candida%') OR
(T.genus = 'Aspergillus' AND T.species LIKE 'niger%') OR
(T.genus = 'Aspergillus' AND T.species LIKE 'sydowii%') OR
(T.genus = 'Aspergillus' AND T.species LIKE 'nidulans%') OR
(T.genus = 'Aspergillus' AND T.species LIKE 'fumigatus%') OR
(T.genus = 'Fusarium' AND T.species LIKE 'oxysporum%') OR
(T.genus = 'Fusarium' AND T.species LIKE 'graminearum%') OR
(T.genus = 'Fusarium' AND T.species LIKE 'proliferatum%') OR
(T.genus = 'Hyaloperonospora' AND T.species LIKE 'arabidopsidis%') OR
(T.genus = 'Magnaporthe' AND T.species LIKE 'grisea%') OR
(T.genus = 'Magnaporthe' AND T.species LIKE 'oryzae%') OR
(T.genus = 'Mycosphaerella' AND T.species LIKE 'graminicola%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'capsici%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'cinnamomi%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'infestans%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'parasitica%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'sojae%') OR
(T.genus = 'Phytophthora' AND T.species LIKE 'ramorum%') OR
(T.genus = 'Plasmopara' AND T.species LIKE 'halstedii%') OR
(T.genus = 'Plasmopara' AND T.species LIKE 'viticola%') OR
(T.genus = 'Plasmopara' AND T.species LIKE 'obducens%') OR
(T.genus = 'Rhynchosporium' AND T.species LIKE 'secalis%') OR
(T.genus = 'Rhynchosporium' AND T.species LIKE 'commune%') OR
(T.genus = 'Rhynchosporium' AND T.species LIKE 'agropyri%') OR
(T.genus = 'Trichoderma' AND T.species LIKE 'harzianum%') OR
(T.genus = 'Trichoderma' AND T.species LIKE 'reesei%') OR
(T.genus = 'Trichoderma' AND T.species LIKE 'citrinoviride%') OR
(T.genus = 'Trichoderma' AND T.species LIKE 'atroviride%') OR
(T.genus = 'Trichoderma' AND T.species LIKE 'asperellum%') OR
(T.genus = 'Ustilago' AND T.species LIKE 'maydis%') OR
(T.genus = 'Ustilago' AND T.species LIKE 'bromivora%')
GROUP BY T.species
" > data/cazome/cazy-cazymes-in-cazy-db-allow-strain-mismatch.csv


# Retrieve CAZymes per CAzy class for each classifier
sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'GH%'
GROUP BY C.classifier
" > data/cazome/classifier-gh-cazymes.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'GT%'
GROUP BY C.classifier
" > data/cazome/classifier-gt-cazymes.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'PL%'
GROUP BY C.classifier
" > data/cazome/classifier-pl-cazymes.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'CE%'
GROUP BY C.classifier
" > data/cazome/classifier-ce-cazymes.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'AA%'
GROUP BY C.classifier
" > data/cazome/classifier-aa-cazymes.csv

sqlite3 -header -csv data/cazy/all_cazy_2022_01_13.db "SELECT COUNT(DISTINCT P.genbank_accession) AS Num_CAZy_Prot_IDs, C.classifier
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.protein_id
INNER JOIN Classifiers AS C ON D.classifier_id = C.classifier_id
INNER JOIN CazyFamilies AS F ON D.family_id = F.family_id
WHERE F.family LIKE 'CBM%'
GROUP BY C.classifier
" > data/cazome/classifier-cbm-cazymes.csv
