# Data analysis and visualisation 

# load libraries to be used
library(here) # for path listing
library(jmv) # for data analyses
library(tidyverse) # for data wrangling (includes ggplot2 two)
library(gridExtra) # for arranging plots

# prepare data
my_data <-
  read.csv( here("Pilot","_data","data_joined.csv"), sep = ";") %>% # read the data set
  mutate(
    Age_group = factor( # format the age group for plotting
      x = Age_group,
      levels = 1:2,
      labels = c("50-60 years old", "70-80 years old"),
      ordered = T
    )
  )


# STATISTICS ----

# print descriptive statistics (exported from jamovi)
jmv::descriptives(
  formula = T1TotalExecutionTime + T1OverallTaskAccuracy + T1CorrectSequencingTotal ~ Age_group,
  data = my_data,
  desc = "rows",
  box = F,
  violin = F,
  dot = F,
  #dotType = "stack",
  boxMean = F,
  missing = F,
  median = T
)

# inference statistics (exported from jamovi)
jmv::ttestIS(
  formula = T1TotalExecutionTime + T1OverallTaskAccuracy + T1CorrectSequencingTotal ~ Age_group,
  data = my_data,
  vars = vars(T1TotalExecutionTime, T1OverallTaskAccuracy, T1CorrectSequencingTotal),
  students = F,
  mann = T,
  effectSize = T
)


# PLOTS ----

# seed for reproducibility
#set.seed(123)

# plot total execution time
plot_execution_time <-
  my_data %>%
  ggplot() +
  aes(x = Age_group, y = T1TotalExecutionTime) +
  geom_violin(width = 1.0, size = 1.0) +
  geom_boxplot(width = 0.5, size = 1.2, colour = "darkblue", fill = "lightblue") +
  geom_dotplot(binaxis = "y", stackdir = "center", alpha = 0.5, dotsize = 2) +
  stat_summary(fun = mean, geom = "point", shape = 15, size = 6, colour = "red3", fill = "red3") +
  labs(x = "Age Group", y = "Total Execution Time (s)") +
  theme_bw(base_size = 14)
  
# plot accuracy  
plot_accuracy <-
  my_data %>%
  ggplot() +
  aes(x = Age_group, y = T1OverallTaskAccuracy) +
  geom_violin(width = 1.0, size = 1.0) +
  geom_boxplot(width = 0.5, size = 1.2, colour = "darkblue", fill = "lightblue") +
  geom_dotplot(binaxis = "y", stackdir = "center", alpha = 0.5, dotsize = 2) +
  stat_summary(fun = mean, geom = "point", shape = 15, size = 6, colour = "red3", fill = "red3") +
  scale_y_continuous( breaks = seq(8,42,2), labels = seq(8,42,2) ) +
  labs(x = "Age Group", y = "Overall Task Accuracy Score (range 8-42)") +
  theme_bw(base_size = 14)


# plot efficiency
plot_efficiency <-
  my_data %>%
  ggplot() +
  aes(x = Age_group, y = T1CorrectSequencingTotal) +
  geom_violin(width = 1.0, size = 1.0) +
  geom_boxplot(width = 0.5, size = 1.2, colour = "darkblue", fill = "lightblue") +
  geom_dotplot(binaxis = "y", stackdir = "center", alpha = 0.5, dotsize = 2) +
  stat_summary(fun = mean, geom = "point", shape = 15, size = 6, colour = "red3", fill = "red3") +
  labs(x = "Age Group", y = "Correct Sequencing Total") +
  theme_bw(base_size = 14)

# arrange the plots
grid.arrange(plot_execution_time, plot_accuracy, plot_efficiency, ncol = 1)


