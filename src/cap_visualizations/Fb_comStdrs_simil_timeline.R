###
# title: "Facebook Community Standards Similarity Timeline (2011-2025)"
# author: "JC De Orellana Sanchez"
###
# —————————————————————
library(pacman)
p_load(tidyverse, lubridate, scales, ggrepel, plotly)

# —————————————————————

# 1) Load & parse dates
timeline_df <- read_csv("timeline_similarity.csv", 
                        col_types = cols(
                          version  = col_character(),
                          origin   = col_double(),
                          previous = col_double()
                        )) %>%
  mutate(
    # pull out 8-digit YYYYMMDD
    vers_str  = str_extract(version, "\\d{8}"),
    # parse it ot date w/ lubridate
    vers_date = ymd(vers_str)
  ) %>%
  filter(!is.na(vers_date))   # drop anything that didn't parse

# —————————————————————
# 2) Pivot for plotting
plot_df <- timeline_df %>%
  pivot_longer(origin:previous, 
               names_to  = "ref", 
               values_to = "sim") %>%
  mutate(
    # create formatted labels column rounded to two decimals
    label = sprintf("%.2f", sim)) %>%
  mutate(label = if_else(label == "1.00", "1", label))

# —————————————————————
# 3) Plot
p <- ggplot(plot_df, aes(x = vers_date, y = sim, color = ref)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  geom_text_repel(
    aes(label = label),
    nudge_y       = 0.02,
    direction     = "y",
    segment.size  = 0.3,
    segment.alpha = 0.5,
    max.overlaps  = Inf,
    size          = 3
  ) +
  coord_cartesian(
    xlim = as.Date(c("2011-01-01", "2025-03-31")),
    ylim = c(0.55, 1.02)
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    expand      = expansion(mult = c(0.02, 0.02))
  ) +
  scale_y_continuous(
    labels = function(x) ifelse(x == 1, "1", sprintf("%.2f", x))
  ) +
  labs(
    title = "Similarity to first version vs. immediate predecessor",
    x     = NULL,
    y     = "Cosine similarity",
    color = NULL
  ) +
  theme_minimal(base_family = "serif", base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    axis.text.x      = element_text(hjust = 0.5),
    panel.grid.minor = element_blank()
  )

print(p)

# —————————————————————
# 4) Interactive version with Plotly
ggplotly(p, tooltip = c("ref", "vers_date", "sim")) %>%
  layout(
    xaxis = list(tickangle = 0),
    yaxis = list(tickformat = ".2f")
  )


# —————————————————————
# 5 Save as png
timeline_plot <- p

ggsave(
  filename = "Fb_comStdrs_simil_timeline.png",
  plot     = timeline_plot,
  width    = 11,    # in inches
  height   = 6,     # in inches
  dpi      = 300,   # print-quality
  bg       = "white"
)

