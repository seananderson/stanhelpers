## stanhelpers

stanhelpers is a small collection of functions to make things that I do with
[Stan](http:://mc-stan.org/) and [rstan](http:://mc-stan.org/rstan.html) easier. The package is a work in progress as I discover and solve bottlenecks.

Install the package with:

```R
# install.packages("devtools")
devtools::install_github("seananderson/stanhelpers")
```

Right now there are only two functions: `sampling_parallel()` and `extract_df()`. 

### `sampling_parallel()`

This function makes it easy to sample from Stan models in parallel (on OS X or Linux). The [rstan wiki](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started#sample-multiple-chains-in-parallel) explains how to sample in parallel, but this takes a lot of extra code. I want it to be as easy to sample in parallel as it is to call the default functions. So, instead of writing the following for every model:

```R
library("parallel")
sflist <- 
mclapply(1:4, mc.cores = 2, 
  function(i) sampling(object = foo, data = foo_data, seed = rng_seed, 
  chains = 1, chain_id = i, refresh = -1))
fit <- sflist2stanfit(sflist)
```

I can just write:

```R
fit <- sampling_parallel(foo, foo_data, chains = 4L)
```

### `extract_df()`

The default function `rstan::extract()` extracts posterior samples from a Stan model. The output is a list containing matrices of samples (where parameters are vectors). `extract_df()` instead extracts the samples and returns them in one of three "tidy data" formats:

1. A list of data frames
2. A single wide data frame
3. A single long-format data frame

These formats should be easier to use with packages such as dplyr, tidyr, or ggplot2. Internally, the data frame columns are renamed with index numbers for each element of a parameter. For example, an underscore would result in column names of `b0_1` and `b0_2` for a variable named `b0` with 2 columns.
