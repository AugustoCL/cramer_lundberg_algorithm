# setup -------------------------------------------------------------------

library(tidyverse)
theme_set(theme_bw())

# reading data ------------------------------------------------------------

result_5k_sim <- 
    read_csv("data/result_5000_simul.csv",
             col_types = list(
                 col_character(),
                 col_double(),
                 col_double(),
                 col_double(),
                 col_double())) %>% 
    mutate(nsim = "5.000 Simul.")

result_50k_sim <- 
    read_csv("data/result_50000_simul.csv",
             col_types = list(
                 col_character(),
                 col_double(),
                 col_double(),
                 col_double(),
                 col_double())) %>% 
    mutate(nsim = "50.000 Simul.")

result_100k_sim <- 
    read_csv("data/result_100000_simul.csv",
             col_types = list(
                 col_character(),
                 col_double(),
                 col_double(),
                 col_double(),
                 col_double())) %>%
    mutate(nsim = "100.000 Simul.")


# plots by # of simulations  --------------------------------------------------------

plot_results <- function(df, nsim, filename){
    df %>% 
        filter(cap_ini<=100000) %>%
        mutate(prob_ruina = prob_ruina_seed_02/100) %>% 
        ggplot(aes(x = cap_ini, y = prob_ruina, color = nseg)) +
        geom_line(size = 1.2, alpha = 1) + 
        geom_point(size = 2) +
        tidyquant::scale_color_tq() +
        labs(x = "Capital Inicial (R$)", 
             y = NULL,
             color = "N° Segurados\nIniciais",
             title = "Probabilidade de Ruína de uma Seguradora",
             subtitle = glue::glue("{nsim} Simulações de Monte Carlo via Cramer-Lundberg - seed 02")) +
        scale_y_continuous(labels = scales::percent) +
        theme(legend.position = c(0.925, 0.842),
              legend.background = element_rect(fill = "white",
                                               color = "black")) +
        ggsave(filename = filename, width = 8, height = 5) 
    
}

plot_results(result_5k_sim, "5.000", "plots_and_images/plot_5k_sim.png")
plot_results(result_50k_sim, "50.000", "plots_and_images/plot_50k_sim.png")
plot_results(result_100k_sim, "100.000", "plots_and_images/plot_100k_sim.png")


# plot w/ all simulations -------------------------------------------------

df_results <- 
    bind_rows(result_100k_sim,
              result_50k_sim,
              result_5k_sim) %>% 
    mutate(nsim = factor(nsim, 
                         levels = c("5.000 Simul.",
                                    "50.000 Simul.",
                                    "100.000 Simul.")))

df_results %>% 
    filter(cap_ini<=100000) %>%
    mutate(prob_ruina = prob_ruina_seed_02/100) %>% 
    ggplot(aes(x = cap_ini, y = prob_ruina, color = nseg)) +
    geom_line(size = 1.2, alpha = 1) + 
    geom_point(size = 2) +
    facet_wrap(~nsim) + 
    tidyquant::scale_color_tq() +
    labs(x = "Capital Inicial (R$)", 
         y = NULL,
         color = "N° Segurados\nIniciais",
         title = "Probabilidade de Ruína de uma Seguradora",
         subtitle = glue::glue("Simulações de Monte Carlo via Cramer-Lundberg - seed 02")) +
    scale_y_continuous(labels = scales::percent) +
    theme_minimal() +
    theme(legend.position = c(0.92, 0.8),
          legend.background = element_rect(fill = "white",
                                           color = "black")) +
    
    ggsave(filename = "plots_and_images/plot_all_simul.png", width = 10, height = 5) 
