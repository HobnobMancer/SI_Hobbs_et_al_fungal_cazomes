pyrewton get_cluster_seqs \
  data/positive_selection/class_seqs/ce_seqs.fasta \
  data/positive_selection/ce_clusters/ce_clusters.csv \
  --output data/positive_selection/ce_clusters/cluster_seqs \ 
  --min_size 10

pyrewton get_cluster_seqs \
  data/positive_selection/class_seqs/pl_seqs.fasta \
  data/positive_selection/pl_clusters/pl_clusters.csv \
  --output data/positive_selection/pl_clusters/cluster_seqs \ 
  --min_size 10

pyrewton get_cluster_seqs \
  data/positive_selection/class_seqs/gh_seqs.fasta \
  data/positive_selection/gh_clusters/gh_clusters.csv \
  --output data/positive_selection/gh_clusters/cluster_seqs \ 
  --min_size 10
