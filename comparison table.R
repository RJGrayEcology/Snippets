##############################################
## Comparison Table
##############################################

library(tidyverse)
library(reshape2)

setwd("pagth/to/your/data")
list.files()

dat_all <- read.csv("your_data.csv")


#-----------------------------------------------
### Helper Function 1: Sum the quantity column by grouped values and get %
# sum.tab <- data %>%
# group_by(Highest_group, Medium_group, Low_group)%>%
#  summarise(n = sum(Count_column))%>%
#  mutate(percentage = round(n/sum(n)*100, 1))

sum.tab <- dat_all%>%
  group_by(Year, ID, Type)%>%
  summarise(n = sum(Quantity))%>%
  mutate(percentage = round(n/sum(n)*100, 1))

### Helper Function 2: rearrange to make the comparison table and pivot wide format
#new_df <- sum.tab %>%
  #pivot_wider(
   # names_from = Group_youre_comparing,
  #  values_from = c(n, percentage),
  #  names_glue = "{.value}_{Group_youre_comparing}"
  #)

new_df <- sum.tab %>%
  pivot_wider(
    names_from = Year,
    values_from = c(n, percentage),
    names_glue = "{.value}_{Year}"
  )

### ---- Clean up the table

# Rename the columns
new_df <- new_df %>%
  rename(n_2022 = n_2022, n_2023 = n_2023, `%_2022` = percentage_2022, `%_2023` = percentage_2023)

# set all NA values to 0 in numeric columns and character to "unknownn"
new_df$Type[is.na(new_df$Type)] <- "Unrecorded"
new_df[is.na(new_df)] <- 0

# Helper function 3: add a percentage difference column (optional)
# new_df$new_change_column <- new_df$perc_col_2 - perc_col_1
new_df$`%_change` <- new_df$`%_2023` - new_df$`%_2022`

write.csv(new_df, "summary_table.csv")
