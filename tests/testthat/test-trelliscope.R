context("trelliscope")

test_that("examples run without barfing", {

  library(dplyr)
  library(tidyr)
  library(purrr)
  library(rbokeh)
  library(ggplot2)

  # tidyverse + rbokeh
  d <- mpg %>%
    group_by(manufacturer, class) %>%
    nest() %>%
    mutate(
      mean_city_mpg = map_dbl(data, ~ mean(.$cty)),
      panel = map_plot(data, ~
        figure(., xlab = "City mpg", ylab = "Highway mpg") %>%
          ly_points(cty, hwy))
    )

  p <- d %>% trelliscope(name = "city_vs_highway_mpg", thumb = FALSE)
  print(p)

  # if you want to use in RStudio Viewer or RMarkdown Notebook, use self_containedd
  # (this will hopefully change, and you should avoid self_contained whenever possible)
  p <- d %>% trelliscope(name = "city_vs_highway_mpg", self_contained = TRUE, thumb = FALSE)
  print(p)

  # set default layout
  p <- d %>% trelliscope(name = "city_vs_highway_mpg", nrow = 2, ncol = 3, thumb = FALSE)
  print(p)

  tf <- tempfile("trelliscopetest")

  # set the output path for where files will be stored
  p <- d %>% trelliscope(name = "city_vs_highway_mpg", path = tf, thumb = FALSE)
  print(p)

  # multiple displays can be added to the same path and all will be available in the viewer
  p <- d %>% trelliscope(name = "city_vs_highway_mpg2", path = tf, thumb = FALSE)
  print(p)

  # ordering the data frame will set default sort order of the display
  p <- d %>%
    arrange(-mean_city_mpg) %>%
    trelliscope(name = "city_vs_highway_mpg", thumb = FALSE)
  print(p)

  # tidyverse + ggplot2
  p <- mpg %>%
    group_by(manufacturer, class) %>%
    nest() %>%
    mutate(
      panel = map_plot(data, ~
        qplot(cty, hwy, data = .) + xlab("cty") + ylab("hwy") +
          xlim(7, 37) + ylim(9, 47) + theme_bw())) %>%
    trelliscope(name = "tidy_gg", thumb = FALSE)
  print(p)

  # computing additional cognostics
  mpg_cog <- mpg %>%
    group_by(manufacturer, class) %>%
    nest() %>%
    mutate(
      cogs = map_cog(data, ~ data_frame(
        mean_city_mpg = mean(.$cty),
        mean_hwy_mpg = mean(.$hwy),
        most_common_drv = tail(names(table(.$drv)), 1)
      )),
      panel = map_plot(data, ~
        figure(., xlab = "City mpg", ylab = "Highway mpg",
          xlim = c(9, 47), ylim = c(7, 37)) %>%
          ly_points(cty, hwy,
            hover = list(year, model))
      )
    )

  p <- mpg_cog %>%
    trelliscope(name = "city_vs_highway_mpg", nrow = 1, ncol = 2, thumb = FALSE)
  print(p)

  # computing additional cognostics explicitly using cog()
  # so we can specify descriptions, etc.
  mpg_cog2 <- mpg %>%
    group_by(manufacturer, class) %>%
    nest() %>%
    mutate(
      cogs = map_cog(data, ~ data_frame(
        mean_city_mpg = cog(mean(.$cty), desc = "Mean city mpg"),
        mean_hwy_mpg = cog(mean(.$hwy), desc = "Mean highway mpg"),
        most_common_drv = cog(tail(names(table(.$drv)), 1), desc = "Most common drive type")
      )),
      panel = map_plot(data, ~
        figure(., xlab = "City mpg", ylab = "Highway mpg",
          xlim = c(9, 47), ylim = c(7, 37)) %>%
          ly_points(cty, hwy,
            hover = list(year, model))
      )
    )

  p <- mpg_cog2 %>%
    trelliscope(name = "city_vs_highway_mpg", nrow = 1, ncol = 2, thumb = FALSE)
  print(p)

  p <- iris %>%
    group_by(Species) %>%
    summarise(
      wiki_link = cog_href(paste0("https://en.wikipedia.org/wiki/Iris_",
        tolower(Species))[1], default_label = TRUE,
        desc = "link to species on wikipedia"),
      panel = panel(figure(xlab = "Sepal Length", ylab = "Sepal Width") %>%
        ly_points(Sepal.Length, Sepal.Width))) %>%
    trelliscope(name = "iris_species", ncol = 3, thumb = FALSE)
  print(p)

  ## ggplot2
  ##---------------------------------------------------------

  p <- qplot(cty, hwy, data = mpg) +
    facet_trelliscope(~ class + manufacturer, self_contained = TRUE)
  print(p)

  # not required, but if you set labels, these will be added as
  # descriptions to the cognostics that are automatically computed
  mpg <- set_labels(mpg, mpg_labels)

  p <- qplot(cty, hwy, data = mpg) +
    theme_bw() +
    facet_trelliscope(~ manufacturer + class, nrow = 2, ncol = 4)
  print(p)

  p <- qplot(class, cty, data = mpg, geom = c("boxplot", "jitter")) +
    facet_trelliscope(~ class, ncol = 7, height = 800, width = 200,
      state = list(sort = list(sort_spec("cty_mean"))), path = "_test",
      scales = c("free", "same")) +
    theme_bw()
  print(p)

  ## cogs
  ##---------------------------------------------------------

  p <- ggplot2::mpg %>%
    group_by(manufacturer, class) %>%
    nest() %>%
    mutate(
      additional_cogs = map_cog(data,
        ~ data_frame(
            max_city_mpg = cog(max(.x$cty), desc = "Max city mpg"),
            min_city_mpg = cog(min(.x$cty), desc = "Min city mpg"))),
      panel = map_plot(data, ~ figure(xlab = "City mpg", ylab = "Highway mpg") %>%
        ly_points(cty, hwy, data = .x))) %>%
    trelliscope(name = "city_vs_highway_mpg", nrow = 1, ncol = 2, thumb = FALSE)
  print(p)

  ## other tidyverse functions

  p <- iris %>%
    nest(-Species) %>%
    mutate(mod = map(data, ~ lm(Sepal.Length ~ Sepal.Width, data = .x))) %>%
    by_row_plot(function(x) {
      figure(xlab = "Sepal.Width", ylab = "Sepal.Length") %>%
        ly_points(x$data[[1]]$Sepal.Width, x$data[[1]]$Sepal.Length) %>%
        ly_abline(x$mod[[1]])
    }) %>%
    trelliscope(name = "iris", thumb = FALSE)
  print(p)

  p <- iris %>%
    nest(-Species) %>%
    mutate(
      mod = map(data, ~ lm(Sepal.Length ~ Sepal.Width, data = .x)),
      cogs = map2_cog(data, mod, function(data, mod) {
        data_frame(max_sl = max(data$Sepal.Length), slope = coef(mod)[2])
      }),
      panel = map2_plot(data, mod, function(data, mod) {
        figure(xlab = "Sepal.Width", ylab = "Sepal.Length") %>%
          ly_points(data$Sepal.Width, data$Sepal.Length) %>%
          ly_abline(mod)
      })) %>%
    trelliscope(name = "iris", thumb = FALSE)
  print(p)

  p <- iris %>%
    nest(-Species) %>%
    mutate(
      mod = map(data, ~ lm(Sepal.Length ~ Sepal.Width, data = .x)),
      cogs = pmap_cog(list(data = data), function(data) {
        data_frame(max_sl = max(data$Sepal.Length))
      }),
      panel = pmap_plot(list(data = data, mod = mod), function(data, mod) {
        figure(xlab = "Sepal.Width", ylab = "Sepal.Length") %>%
          ly_points(data$Sepal.Width, data$Sepal.Length) %>%
          ly_abline(mod)
      })) %>%
    trelliscope(name = "iris", thumb = FALSE)
  print(p)

})
