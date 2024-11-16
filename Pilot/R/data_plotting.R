# Plotting of the data for the Pilot NOT-CZ project


# PREPARE LABELS ----
prepare_labels <- function(y, x, labs) data.frame(
  
  var_name = c(x, y), # variable name in the data
  plot_lab = labs, # label for the plot
  var_type = c( "IV", rep("DV", length(y) ) ) # type of variable
  
)

# VIOLIN-/BOX-/DOT-PLOT COMBO ----
plot_data <- function(data, y_vars, x_var, labs, seed = 123) {
  
  # prepare the data by pivoting to a longer format
  data <-
    data %>%
    select( all_of( c("ParticipantID", y_vars, x_var) ) ) %>% # keep only variables of interest
    pivot_longer(cols = all_of(y_vars), names_to = "Type", values_to = "Score") %>% # change data format from wide to long
    mutate( Type = unlist(sapply( Type, function(i) with(labs, plot_lab[var_name == i]) ), use.names = F) ) # change names for plotting
    
  # seed for reproducibility
  set.seed(seed)
  
  # plot and return it
  data %>%
    ggplot() +
    aes(x = get(x_var), y = Score) +
    geom_violin(width = 1.0, size = 1.0) +
    geom_boxplot(width = 0.5, size = 1.2, colour = "darkblue", fill = "lightblue") +
    geom_dotplot(binaxis = "y", stackdir = "center", alpha = 0.5, dotsize = 2) +
    stat_summary(fun = mean, geom = "point", shape = 15, size = 6, colour = "red3", fill = "red3") +
    labs(x = with(labs, plot_lab[var_type == "IV"]), y = "Score") +
    facet_wrap( ~ Type, ncol = 1, scales = "free_y") +
    theme_bw(base_size = 14)
  
}


# CORRELATION PLOT ----
plot_correlations <- function(data, labels) data %>%
  
  select( all_of( c(labels$var_name) ) ) %>% # keep only variables of interest
  mutate( Age_group = as.character(Age_group) ) %>% # re-format Age_group for better colours scaling
  ggpairs(
    
    mapping = ggplot2::aes(colour = Age_group), # colour mapping
    lower = list(continuous = wrap("smooth", alpha = 0.3, size = 2), combo = "blank" ), # lower triangle
    diag = list(discrete = "barDiag", continuous = wrap("densityDiag", alpha = 0.5 ) ), # diagonal
    upper = list(combo = wrap("box_no_facet", alpha = 0.5), continuous = wrap("cor", method = "spearman", size = 4) ), # upper triangle
    columnLabels = sapply( colnames(.), function(x) with(labels, plot_lab[var_name == x] ) ), # labels
    axisLabels = "show"
    
  ) +
  theme_bw() +
  theme( panel.grid = element_blank() )
