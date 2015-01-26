#' Sample from a Stan model in parallel
#'
#' Sample from a Stan model in parallel (on Unix-like machines). This is simply
#' a wrapper for the code on the \pkg{rstan} wiki to make it simple to sample
#' from Stan models without writing lots of code each time.
#'
#' @param object An object of class \code{stanmodel}. E.g., an object returned
#'   by \code{\link[rstan]{stan_model}}.
#' @param data An object of class \code{list} containing data to be passed to
#'   \code{\link[rstan]{stan}}.
#' @param chains Positive integer giving the number of chains to pass to
#'   \code{\link[rstan]{stan}}.
#' @param cores Positive integer giving the number of cores to use. Passed
#'   to the \code{mc.cores} argument in \code{\link[parallel]{mclapply}}.
#' @param rng_seed An optional value to pass to \code{\link[base]{set.seed}}.
#' @param ... Anything else to pass to \code{\link[rstan]{stan}}.
#' @export
#'
#' @return An S4 object of class \code{stanfit} as returned from
#'   \code{\link[rstan]{stan}}. The multiple chains have been joined into a
#'   single model object.
#'
#' @importFrom parallel mclapply
#' @importFrom rstan sflist2stanfit stan sampling
#' @references https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
#'
#' @examples
#' \dontrun{
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
#' fit <- sampling_parallel(sm, schools_dat, cores = 4L)
#' fit
#' }

sampling_parallel <- function(object, data, chains = 4L, cores = 2L,
  rng_seed = NULL, ...) {

  if(is.null(rng_seed)) rng_seed <- sample(seq_len(1e5), 1L)

  sflist <- mclapply(seq_len(chains), mc.cores = cores,
      function(i) sampling(object = object, data = data,
        seed = rng_seed, chains = 1L, chain_id = i,
        ...))
  sflist2stanfit(sflist)
}
