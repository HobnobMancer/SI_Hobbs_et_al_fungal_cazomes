DB="data/cazy/all_cazy_2020_01_13.db"


"WITH dbcanProteins (dbcanDomains) AS (
	SELECT domain_id
	FROM Domains
	INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
	WHERE Classifiers.classifier = 'dbCAN'
), cazyProteins (cazyDomains) AS (
	SELECT domain_id
	FROM Domains
	INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
	WHERE Classifiers.classifier = 'CAZy'
)
SELECT DISTINCT Proteins.genbank_accession, CazyFamilies.family, Classifiers.classifier
FROM Proteins
INNER JOIN Domains on Proteins.protein_id = Domains.protein_id
INNER JOIN CazyFamilies on Domains.family_id = CazyFamilies.family_id
INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
LEFT JOIN dbcanProteins ON Domains.domain_id = dbcanProteins.dbcanDomains
LEFT JOIN cazyProteins ON Domains.domain_id = cazyProteins.cazyDomains
WHERE CazyFamilies.family like 'CE%' AND
	Domains.domain_id IN dbcanProteins AND
	Domains.domain_id IN cazyProteins
"



# generate lists of protein IDs

sqlite3 $DB "
SELECT DISTINCT Proteins.genbank_accession
FROM Proteins
INNER JOIN Domains on Proteins.protein_id = Domains.protein_id
INNER JOIN CazyFamilies on Domains.family_id = CazyFamilies.family_id
INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
WHERE CazyFamilies.family like 'CE%' and Classifiers.classifier = 'dbCAN'
" > data/positive_selection/class_prot_ids/ce_ids

sqlite3 $DB "
SELECT DISTINCT Proteins.genbank_accession
FROM Proteins
INNER JOIN Domains on Proteins.protein_id = Domains.protein_id
INNER JOIN CazyFamilies on Domains.family_id = CazyFamilies.family_id
INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
WHERE CazyFamilies.family like 'PL%' and Classifiers.classifier = 'dbCAN'
" > data/positive_selection/class_prot_ids/pl_ids

sqlite3 $DB "
SELECT DISTINCT Proteins.genbank_accession
FROM Proteins
INNER JOIN Domains on Proteins.protein_id = Domains.protein_id
INNER JOIN CazyFamilies on Domains.family_id = CazyFamilies.family_id
INNER JOIN Classifiers on Domains.classifier_id = Classifiers.classifier_id
WHERE CazyFamilies.family like 'GH%' and Classifiers.classifier = 'dbCAN'
" > data/positive_selection/class_prot_ids/gh_ids

# Extract protein sequences
pyrewton extract_db_seqs $DB data/positive_selection/class_prot_ids/ce_ids -o data/positive_selection/class_seqs/ce_seqs.fasta
pyrewton extract_db_seqs $DB data/positive_selection/class_prot_ids/pl_ids -o data/positive_selection/class_seqs/pl_seqs.fasta
pyrewton extract_db_seqs $DB data/positive_selection/class_prot_ids/gh_ids -o data/positive_selection/class_seqs/gh_seqs.fasta
