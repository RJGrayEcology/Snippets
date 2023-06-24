#######################################
### Word clouds and word frequencies
#######################################

setwd("your/file/path")
list.files()

library(wordcloud)
library(tidytext)
library(tidyverse)
library(RColorBrewer)
library(readxl)

dat <- read_xlsx("yourdata.xlsx")

### ----- Helper function 1: word cloud function
# wordcloud(cloud_vector, colors = color_palette)


### ----- Helper function 2: count word frequencies
#words <- dat %>%
#  unnest_tokens(word,vector_column) %>%
#  count(word, sort = TRUE)
#words


