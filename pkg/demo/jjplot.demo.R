require("reshape")

### Simple bar plot example with a color scale ###
df <- data.frame(x = 1:50,
                 y = rnorm(50))

jjplot(y ~ bar() : color(y) + x, data = df)

### Line plot of the same data, annotated with mean ## #
jjplot(y ~ hline(lty = "dashed", col = "red") : fun.y(mean) +
           line() + point() + x, data = df)

### Box plot example ###
df <- data.frame(state = rownames(state.x77),
                 region = state.region,
                 state.x77)
jjplot(Income ~ box() : color(region) : group(quantile(), by=region) +
                region, data = df)

### Same data, faceted by sub-scatterplots instead of boxplots ###
jjplot(Murder ~ (abline() : group(fit(), by = region) + point()) :
                color(region) + Income,
       data = df, facet.y = region)

### Bar plot example using the table statistic ###
df <- data.frame(x = sample(factor(LETTERS[1:10]), 100, replace=TRUE))
jjplot(~ bar(width = 0.5) : table() + x, data = df)

### Heatmap-style scatter plot ###
df <- data.frame(state = rownames(state.x77),
                 region = state.region,
                 t((t(state.x77) - colMeans(state.x77)) /
                   apply(state.x77, 2, sd)))

melted <- melt(df, id.vars = c("state", "region"))

jjplot(state ~ point(size = 2, shape = 22) : color(value) + variable,
       data = melted, xlab = "", ylab = "")

### Example of the jitter statistic to make a pseudo box-plot ###
df <- data.frame(x = rnorm(10000) + (1:4) * 1,
                 f = factor(1:4))
df$y <- c(-6, -2, 2, 4) * df$x + rnorm(10000)
jjplot(f ~ point(alpha = 0.10) : jitter() : color(f) + x, data =df)

### Using grouping and statistics to create best-fit lines for each factor ###
jjplot(y ~ hline(lty = "dashed") : fun.y(mean) +
           (abline() : group(fit(), by = f) + point(alpha = 0.10)) : color(f) +
           (x + 2), data = df)

### CCDF of a heavy tailed distribution.
df <- data.frame(x=rlnorm(1000,2,2.5))
jjplot(~ point() : log(x, y) : ccdf(density = TRUE) + x, data = df)

### Histogram of the same distribution.
jjplot( ~ bar(width = 0.2) : hist(align = "left", density = FALSE) : log(x) + x,
       data = df)

## Heatmaps with tile.
## Also shows off themes, and axis parameters
jjplot(Sepal.Width ~ point() +
       tile(border = NA) : color(z) :
       group(density2d(n = 32), by = Species) + (Petal.Width + 0.25),
       data = iris,
       theme = jjplot.theme("bw",
         x.axis.type = "exact",
         y.axis.type = "exact"),
       facet.x = Species)
