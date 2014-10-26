## stanhelpers

stanhelpers is just a collection of functions to make things that I do with
Stan and rstan easier to do.

Right now there is only one function: `sampling_parallel()`. This function makes it easy to sample from Stan models in parallel. The [rstan wiki](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started#sample-multiple-chains-in-parallel) explains how to sample in parallel, but this takes a lot of extra code. I want it to be as easy to sample in parallel as it is to call the default funtions. So, instead of writing the following for every model:

```S
library(parallel)
sflist <- 
mclapply(1:4, mc.cores = 2, 
  function(i) sampling(object = foo, data = foo_data, seed = rng_seed, 
  chains = 1, chain_id = i, refresh = -1))
fit <- sflist2stanfit(sflist)
```

I can just write:

```S
fit <- sampling_parallel(foo, foo_data, chains = 4L)
```

I also plan to add a number of functions for manipulating the posterior samples
and making them quick to visualize.

Install the package with:

```S
# install.packages("devtools")
devtools::install_github("seananderson/stanhelpers")
```
