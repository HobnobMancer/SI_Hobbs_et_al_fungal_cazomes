DB="data/cazome/cazome.db"

sqlite3 $DB "
SELECT DISTINCT P.genbank_accession
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.domain_id
INNER JOIN Classifier AS C ON D.classifier_id = C.classifier_id
WHERE C.classifier = 'CAZy'
" > data/cazome/cazy_protein_ids

pyrewton extract_db_seqs $DB ata/cazome/cazy_protein_ids -o data/positive_selection/cazy_seqs.fasta

sqlite3 $DB "
SELECT DISTINCT P.genbank_accession
FROM Proteins AS P
INNER JOIN Domains AS D ON P.protein_id = D.domain_id
INNER JOIN Classifier AS C ON D.classifier_id = C.classifier_id
WHERE C.classifier = 'dbCAN'
" > data/cazome/dbcan_protein_ids

pyrewton extract_db_seqs $DB ata/cazome/cazy_protein_ids -o data/positive_selection/dbcan_seqs.fasta

pyrewton get_cluster_summary \
  data/positive_selection/cazy_seqs.fasta \
  data/positive_selection/dbcan_seqs.fasta \
  data/positive_selection/ce_clusters/ce_clusters.csv 

pyrewton get_cluster_summary \
  data/positive_selection/cazy_seqs.fasta \
  data/positive_selection/dbcan_seqs.fasta \
  data/positive_selection/ce_clusters/pl_clusters.csv 

pyrewton get_cluster_summary \
  data/positive_selection/cazy_seqs.fasta \
  data/positive_selection/dbcan_seqs.fasta \
  data/positive_selection/ce_clusters/gh_clusters.csv 
