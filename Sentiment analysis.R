######################################################
#### Sentiment Analysis
######################################################

# read in libraries
library(syuzhet)
library(ggplot2)
library(tidyverse)
library(wordcloud)
library(stringr)

# set working directory with data
setwd("You/path/goes/here")
list.files()

# read in data
dat <- read.csv("your_data.csv")

# convert to character vector to prepare analysis
open_end <- iconv(dat$your_open_ended_responses)

# check the wordcloud
wordcloud(open_end, colors = brewer.pal(10, "Spectral"),
          min.freq = 20)

# get sentiments
s1 <- get_nrc_sentiment(open_end)
head(s1)

# check on carplot
barplot(colSums(s1),
        las = 2,
        col = brewer.pal(10, "Spectral"),
        ylab = 'Count',
        main = 'Sentiment Scores of Responses')



