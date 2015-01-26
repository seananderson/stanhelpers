#' Extract samples from a Stan model in a data frame format
#'
#' Returns extracted samples from a Stan model in a data frame format. This
#' makes it easier to work with the output using, for example, the dplyr or
#' ggplot2 packages.
#'
#' @param x A sampled Stan model
#' @param output Should the samples be returned as a list of data frames
#'   (\code{"list"}), as one wide data frame (\code{"wide_df"}), or as one long
#'   data frame (\code{"long_df"})?
#' @param sep A separator between the variable name and indices when naming
#'   columns. E.g. an underscore would result in \code{b0_1} and \code{b0_2} for
#'   a variable named \code{b0} with 2 columns.
#' @importFrom rstan extract
#' @importFrom reshape2 melt
#' @export
#'
#' @examples
#' \donttest{
#' schools_code <- "data {
#'   int<lower=0> J; // number of schools
#'   real y[J]; // estimated treatment effects
#'   real<lower=0> sigma[J]; // s.e. of effect estimates
#' }
#' parameters {
#'   real mu;
#'   real<lower=0> tau;
#'   real eta[J];
#' }
#' transformed parameters {
#'   real theta[J];
#'   for (j in 1:J)
#'     theta[j] <- mu + tau * eta[j];
#' }
#' model {
#'   eta ~ normal(0, 1);
#'   y ~ normal(theta, sigma);
#' }"
#'
#' schools_dat <- list(
#'   J = 8,
#'   y = c(28,  8, -3,  7, -1,  1, 18, 12),
#'   sigma = c(15, 10, 16, 11,  9, 11, 10, 18))
#'
#' sm <- rstan::stan_model(model_code = schools_code)
#' fit <- sampling(sm, schools_dat, iter = 100, chains = 1)
#' str(rstan::extract(fit))
#' str(extract_df(fit))
#' head(extract_df(fit, "wide_df"))
#' head(extract_df(fit, "long_df"))
#' }

extract_df <- function(x, output = c("list", "wide_df", "long_df"), sep = "_") {

  e <- extract(x)
  x <- lapply(e, as.data.frame)
  z <- lapply(seq_along(x), function(i) {
    zi <- setNames(x[[i]], paste0(names(x)[i], sep, seq_along(names(x[[i]]))))
    # don't number single columns:
    if (ncol(x[[i]]) == 1) names(zi) <- sub(paste0(sep, 1), "", names(zi))
    row.names(zi) <- NULL
    zi
  })

  output <- match.arg(output)
  switch(output,
    list = {
      names(z) <- names(x)
      z},
    wide_df = do.call("cbind", z),
    long_df = melt(do.call("cbind", z))
  )
}
