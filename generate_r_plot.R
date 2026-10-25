# Load library
library(ggplot2)

cat("Reading virulence data...\n")
# Read data (tab-separated)
df <- read.delim("results/downstream/ERR3335404_virulence.csv", sep="\t", stringsAsFactors=FALSE)

# Clean contig names (remove the length and coverage tags)
df$Clean_Contig <- sapply(strsplit(df$SEQUENCE, "_length"), `[`, 1)

# Count how many virulence genes are on each contig
counts <- as.data.frame(table(df$Clean_Contig))
colnames(counts) <- c("Contig", "Count")

# Sort descending and take the top 10
counts <- counts[order(-counts$Count), ]
counts <- head(counts, 10)

# Lock in the factor levels so ggplot doesn't reorder them alphabetically
counts$Contig <- factor(counts$Contig, levels = rev(counts$Contig))

# Define an aesthetic, high-contrast professional color palette
aesthetic_colors <- c("#E63946", "#F4A261", "#E9C46A", "#2A9D8F", "#264653", 
                      "#8AB17D", "#B5838D", "#6D6875", "#FFB703", "#FB8500")

cat("Generating aesthetic plot...\n")
# Create the plot
p <- ggplot(counts, aes(x = Contig, y = Count, fill = Contig)) +
  geom_bar(stat = "identity", color = "black", linewidth = 0.8, show.legend = FALSE) +
  scale_fill_manual(values = aesthetic_colors) +
  coord_flip() +
  geom_text(aes(label = Count), hjust = -0.4, fontface = "bold", color = "black", size = 5.5) +
  labs(title = "Virulence Gene Distribution (M. ulcerans)",
       x = "Contig (Node)",
       y = "Total Virulence Genes Detected") +
  theme_minimal(base_size = 15) +
  theme(
    text = element_text(color = "black", face = "bold"),
    plot.title = element_text(size = 20, hjust = 0.5, margin = margin(b = 20)),
    axis.title.x = element_text(size = 16, margin = margin(t = 15)),
    axis.title.y = element_text(size = 16, margin = margin(r = 15)),
    axis.text.x = element_text(size = 14, color = "black"),
    axis.text.y = element_text(size = 14, color = "black"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E0E0E0", linewidth = 0.5),
    axis.line = element_line(color = "black", linewidth = 1.2),
    plot.margin = margin(20, 30, 20, 20)
  ) +
  expand_limits(y = max(counts$Count) * 1.15) # Add breathing room for the text labels

# Save as a 600 DPI PNG
output_path <- "results/downstream/virulence_distribution_600dpi.png"
ggsave(output_path, plot = p, width = 11, height = 7, dpi = 600, bg = "white")

cat(paste("Success! 600 DPI plot saved to:", output_path, "\n"))
