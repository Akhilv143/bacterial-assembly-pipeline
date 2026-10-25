library(ggplot2)

cat("Reading Prokka summary...\n")
# Read the Prokka txt summary file
lines <- readLines("results/prokka/ERR3335404/ERR3335404.txt")

# Extract the feature counts (ignoring the organism/contig lines at the top)
features <- lines[grep("CDS|tRNA|rRNA|tmRNA", lines)]
feature_names <- trimws(sub(":.+", "", features))
feature_counts <- as.numeric(trimws(sub(".+:", "", features)))

df <- data.frame(Feature = feature_names, Count = feature_counts)

aesthetic_colors <- c("#2A9D8F", "#E9C46A", "#F4A261", "#264653")

cat("Generating inventory plot...\n")
p <- ggplot(df, aes(x = reorder(Feature, Count), y = Count, fill = Feature)) +
  geom_bar(stat = "identity", color = "black", linewidth = 0.8, show.legend = FALSE) +
  scale_fill_manual(values = aesthetic_colors) +
  geom_text(aes(label = Count), vjust = -0.5, fontface = "bold", size = 5) +
  labs(title = "Prokka Genome Annotation Inventory",
       x = "Genomic Feature",
       y = "Count") +
  theme_minimal(base_size = 15) +
  theme(
    text = element_text(color = "black", face = "bold"),
    plot.title = element_text(size = 20, hjust = 0.5, margin = margin(b = 20)),
    axis.title.x = element_text(margin = margin(t = 15)),
    axis.title.y = element_text(margin = margin(r = 15)),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 1)
  ) +
  expand_limits(y = max(df$Count) * 1.15)

output_path <- "results/downstream/prokka_inventory_600dpi.png"
ggsave(output_path, plot = p, width = 8, height = 7, dpi = 600, bg = "white")
cat(paste("Success! Plot saved to:", output_path, "\n"))
