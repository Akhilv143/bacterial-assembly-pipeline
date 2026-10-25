library(ggplot2)

cat("Parsing SPAdes fasta headers...\n")
# Extract headers directly from the fasta file
headers <- system("grep '^>' results/spades/ERR3335404/contigs.fasta", intern = TRUE)

# Parse out the length and coverage values using regex
lengths <- as.numeric(sub(".*length_([0-9]+)_.*", "\\1", headers))
coverages <- as.numeric(sub(".*cov_([0-9.]+).*", "\\1", headers))

df <- data.frame(Length = lengths, Coverage = coverages)

# Filter out tiny fragments under 500bp for a cleaner plot
df <- subset(df, Length > 500)

cat("Generating aesthetic scatter plot...\n")
p <- ggplot(df, aes(x = Length, y = Coverage)) +
  geom_point(alpha = 0.7, color = "#E63946", size = 3) +
  scale_x_log10(labels = scales::comma) + 
  labs(title = "Contig Length vs. Sequencing Coverage",
       subtitle = "M. ulcerans (SPAdes Assembly)",
       x = "Contig Length (bp, log scale)",
       y = "K-mer Coverage") +
  theme_minimal(base_size = 15) +
  theme(
    text = element_text(color = "black", face = "bold"),
    plot.title = element_text(size = 20, hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5, margin = margin(b = 15), color = "#555555"),
    axis.title.x = element_text(margin = margin(t = 15)),
    axis.title.y = element_text(margin = margin(r = 15)),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", linewidth = 1)
  )

output_path <- "results/downstream/coverage_vs_length_600dpi.png"
ggsave(output_path, plot = p, width = 10, height = 6, dpi = 600, bg = "white")
cat(paste("Success! Plot saved to:", output_path, "\n"))
