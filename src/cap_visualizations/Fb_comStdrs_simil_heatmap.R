###
# title: "Facebook Community Standards Version Similarity Heatmap (2011-2025)"
# author: "JC De Orellana Sanchez"
###

library(tidyverse)
library(lubridate)  # easy date parsing
library(viridis) # color-blind sensitive

# setwd() to matrix file path

# 1) Read the CSV and pull the first column into 'rowname'
sim_raw <- read_csv("doc_similarity_matrix.csv", show_col_types = FALSE) %>%
  rename_with(~ "rowname", 1)

# 2) Pivot to long form
sim_long <- sim_raw %>%
  pivot_longer(-rowname,
               names_to  = "colname",
               values_to = "sim")

# 3) Extract the DATE (YYYYMMDD) from each capture name
sim_long <- sim_long %>%
  mutate(
    row_date = as_date(str_extract(rowname, "\\d{8}"), "%Y%m%d"),
    col_date = as_date(str_extract(colname, "\\d{8}"), "%Y%m%d")
  ) %>%
  drop_na(row_date, col_date)

# 4) Keep only one triangle (row ≤ returns the lower half)
sim_tri <- sim_long %>%
  filter(row_date <= col_date)

# 5) Build a two‐dec raw label, strip leading “0” or “.00”, and pick text color
sim_tri <- sim_tri %>%
  mutate(
    sim_round     = sprintf("%.2f", sim),       # Round sim to second decimal
    label   = sim_round 
    %>% sub("^0\\.", ".", .)   %>%              # 0.86 → .86
      sub("\\.00$",   "", .),                     # 1.00 → 1
    textcol = ifelse(sim > 0.7, "black", "white")           # choose contrast
  )

# 6) Turn the dates into factors so calendar order is respected
all_dates <- sort(unique(c(sim_tri$row_date, sim_tri$col_date)))

sim_tri <- sim_tri %>%
  mutate(
    row_date = factor(row_date, levels = all_dates),
    col_date = factor(col_date, levels = all_dates)
  )

# 7) Plot

simil_heat <- 
  ggplot(sim_tri, aes(x = col_date, y = row_date, fill = sim)) +
  geom_tile(color = "white", width = 1, height = 1) +
  # map color per-tile via an identity scale
  geom_text(aes(label = label, color = textcol),
            size = 3, family = "serif", show.legend = FALSE) +
  scale_fill_viridis_c(option = "viridis", name = "Cosine\nSimilarity") +
  scale_color_identity() + 
  coord_fixed() +
  labs(
    title = "Community Standards similarity (version-level)",
    x     = NULL, 
    y     = NULL
  ) +
  theme_minimal(base_family = "serif", base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    axis.text.x     = element_text(angle = 45, hjust = 1),
    panel.grid      = element_blank()
  )

print(simil_heat)

# —————————————————————
# 8 Save as png
ggsave(
  filename = "Fb_comStdrs_simil_heatmap.png",
  plot     = simil_heat,
  width    = 11,    # in inches
  height   = 6,     # in inches
  dpi      = 300,   # print-quality
  bg       = "white"
)


