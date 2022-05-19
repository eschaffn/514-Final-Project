library(rjson)
library(ggplot2)
library(ggpubr)

result <- fromJSON(file = "json_data.json")
summary(result)

en_nouns <- result$en_nouns
en_verbs <- result$en_verbs
en_adjs <- result$en_adjs

fr_nouns <- result$fr_nouns
fr_verbs <- result$fr_verbs
fr_adjs <- result$fr_adjs


en_nouns_10000 <- sample(en_nouns, replace = FALSE, size = 10000)
fr_nouns_10000 <- sample(fr_nouns, replace = FALSE, size = 10000)
en_verbs_10000 <- sample(en_verbs, replace = FALSE, size = 10000)
fr_verbs_10000 <- sample(fr_verbs, replace = FALSE, size = 10000)
en_adjs_10000 <- sample(en_adjs, replace = FALSE, size = 10000)
fr_adjs_10000 <- sample(fr_adjs, replace = FALSE, size = 10000)

en_nouns_sorted <- sort(en_nouns_10000)
fr_nouns_sorted <- sort(fr_nouns_10000)
en_verbs_sorted <- sort(en_verbs_10000)
fr_verbs_sorted <- sort(fr_verbs_10000)
en_adjs_sorted <- sort(en_adjs_10000)
fr_adjs_sorted <- sort(fr_adjs_10000)

en_nouns_cosine <- round(en_nouns_sorted, digits = 2)
fr_nouns_cosine <- round(fr_nouns_sorted, digits = 2)
en_verbs_cosine <- round(en_verbs_sorted, digits = 2)
fr_verbs_cosine <- round(fr_verbs_sorted, digits = 2)
en_adjs_cosine <- round(en_adjs_sorted, digits = 2)
fr_adjs_cosine <- round(fr_adjs_sorted, digits = 2)

en_nouns_df <- as.data.frame(table(en_nouns_cosine))
en_nouns_df <- en_nouns_df[order(en_nouns_df$Freq, decreasing = TRUE), ]
fr_nouns_df <- as.data.frame(table(fr_nouns_cosine))
fr_nouns_df <- fr_nouns_df[order(fr_nouns_df$Freq, decreasing = TRUE), ]

en_verbs_df <- as.data.frame(table(en_verbs_cosine))
en_verbs_df <- en_verbs_df[order(en_verbs_df$Freq, decreasing = TRUE), ]
fr_verbs_df <- as.data.frame(table(fr_verbs_cosine))
fr_verbs_df <- fr_verbs_df[order(fr_verbs_df$Freq, decreasing = TRUE), ]

en_adjs_df <- as.data.frame(table(en_adjs_cosine))
en_adjs_df <- en_adjs_df[order(en_adjs_df$Freq, decreasing = TRUE), ]
fr_adjs_df <- as.data.frame(table(fr_adjs_cosine))
fr_adjs_df <- fr_adjs_df[order(fr_adjs_df$Freq, decreasing = TRUE), ]

en_noun_plot <- ggplot(en_nouns_df, aes(y = Freq, x = as.numeric(as.character(en_nouns_cosine)))) +
  geom_point(size = .8) +
    coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
      xlab("Similarity Score") +
        ggtitle("English Nouns") + 
          theme(
            plot.margin = margin(0,0,0,0, "pt"),
            axis.text = element_text(size = rel(.5)),
            axis.title = element_text(size = rel(.5)),
            plot.title = element_text(size = rel(.7))
            )

fr_noun_plot <- ggplot(fr_nouns_df, aes(y = Freq, x = as.numeric(as.character(fr_nouns_cosine)))) +
  geom_point(size = .8) +
  coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
  xlab("Similarity Score") +
  ggtitle("French Nouns") + 
  theme(
    plot.margin = margin(0,0,0,0, "pt"),
    axis.text = element_text(size = rel(.5)),
    axis.title = element_text(size = rel(.5)),
    plot.title = element_text(size = rel(.7))
  )

en_verb_plot <- ggplot(en_verbs_df, aes(y = Freq, x = as.numeric(as.character(en_verbs_cosine)))) +
  geom_point(size = .8) +
  coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
  xlab("Similarity Score") +
  ggtitle("English Verbs") + 
  theme(
    plot.margin = margin(0,0,0,0, "pt"),
    axis.text = element_text(size = rel(.5)),
    axis.title = element_text(size = rel(.5)),
    plot.title = element_text(size = rel(.7))
  )

fr_verb_plot <- ggplot(fr_verbs_df, aes(y = Freq, x = as.numeric(as.character(fr_verbs_cosine)))) +
  geom_point(size = .8) +
  coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
  xlab("Similarity Score") +
  ggtitle("French Verbs") + 
  theme(
    plot.margin = margin(0,0,0,0, "pt"),
    axis.text = element_text(size = rel(.5)),
    axis.title = element_text(size = rel(.5)),
    plot.title = element_text(size = rel(.7))
  )

en_adj_plot <- ggplot(en_adjs_df, aes(y = Freq, x = as.numeric(as.character(en_adjs_cosine)))) +
  geom_point(size = .8) +
  coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
  xlab("Similarity Score") +
  ggtitle("English Adjectives") + 
  theme(
    plot.margin = margin(0,0,0,0, "pt"),
    axis.text = element_text(size = rel(.5)),
    axis.title = element_text(size = rel(.5)),
    plot.title = element_text(size = rel(.7))
  )

fr_adj_plot <- ggplot(fr_adjs_df, aes(y = Freq, x = as.numeric(as.character(fr_adjs_cosine)))) +
  geom_point(size = .8) +
  coord_cartesian(xlim = c(-.8, .8), expand = TRUE) + 
  xlab("Similarity Score") +
  ggtitle("French Adjectives") + 
  theme(
    plot.margin = margin(0,0,0,0, "pt"),
    axis.text = element_text(size = rel(.5)),
    axis.title = element_text(size = rel(.5)),
    plot.title = element_text(size = rel(.7))
  )

ggarrange(en_noun_plot, fr_noun_plot,
          en_verb_plot, fr_verb_plot,
          en_adj_plot, fr_adj_plot,
          labels = c("English Nouns", "French Nouns",
                    "English Verbs", "French Verbs",  
                    "English Adjectives", "French Adjectives"))
en_means <- as.data.frame(c(mean(as.numeric(as.character(en_nouns_df$en_nouns_cosine))),
                            mean(as.numeric(as.character(en_verbs_df$en_verbs_cosine))),
                            mean(as.numeric(as.character(en_adjs_df$en_adjs_cosine)))))

colnames(en_means) <- ("Mean")
rownames(en_means) <- c("nouns", "verbs", "adjs")



fr_means <- as.data.frame(c(mean(as.numeric(as.character(fr_nouns_df$fr_nouns_cosine))),
                            mean(as.numeric(as.character(fr_verbs_df$fr_verbs_cosine))),
                            mean(as.numeric(as.character(fr_adjs_df$fr_adjs_cosine)))))

colnames(fr_means) <- ("Mean")
rownames(fr_means) <- c("nouns", "verbs", "adjs")

