### GEOMS ###
.is.geom <- function(layer.call) {
  return(is.call(layer.call) && exists(eval(paste('jjplot.geom',as.character(layer.call[[1]]),sep='.'))))
}

jjplot.geom.line <- function(state,
                             color = NULL,
                             lty = "solid",
                             lwd = 1.5,
                             size = NULL,
                             ordered = TRUE) {
  if (nrow(state$data) == 0) {
    return(NULL)
  }
  if (ordered) {
    oo <- order(state$data$x)
  } else {
    oo <- 1:nrow(state$data)
  }
  
  if (!is.null(state$data$color) && is.null(color))  {
    by(state$data[oo,], state$data$color[oo],
       function(zz) {
         grid.segments(zz$x[-length(zz$x)], zz$y[-length(zz$y)],
                       zz$x[-1], zz$y[-1],
                       default.units = "native",
                       gp = gpar(col = .match.scale(color, zz$color, state$scales),
                         lwd = lwd,
                         lex = .match.scale(size, zz$size, state$scales, type="size"),
                         lty = lty))
       })
  } else {
    grid.lines(x = state$data$x[oo], y = state$data$y[oo],
               default.units = "native",
               gp = gpar(col = .match.scale(color, state$data$color[oo], state$scales),
                 lwd = lwd,
                 lex = .match.scale(size, state$data$size[oo], state$scales, type="size"),
                 lty = lty))
  }
}

jjplot.geom.bar <- function(state,
                            alpha = NULL,
                            color = NULL,
                            border = NULL,
                            width = 1,
                            horizontal = FALSE) {
  if (horizontal) {
    grid.rect(0, 
              state$data$y,
              state$data$x,
              width,              
              just = c("left", "center"),
              default.units = "native",
              gp = gpar(fill = .match.scale(color, state$data$color, state$scales),
                alpha = .match.scale(alpha, state$data$alpha, state$scales, type="alpha"),
                col = .match.scale(border, state$data$border, state$scales, type = "border")))
  } else {
    grid.rect(state$data$x,
              0,
              width,
              state$data$y,
              just = c("center", "bottom"),
              default.units = "native",
              gp = gpar(fill = .match.scale(color, state$data$color, state$scales),
                alpha = .match.scale(alpha, state$data$alpha, state$scales, type="alpha"),
                col = .match.scale(border, state$data$border, state$scales, type = "border")))
  }
}

jjplot.geom.tile <- function(state,
                             color = NULL,
                             border = NULL,
                             lty = "solid",
                             lwd = 1.0,
                             just = c("center","center"),
                             hjust = NULL,
                             vjust = NULL) {
  distances.x <- diff(sort(as.numeric(state$data$x)))
  min.dist.x <- min(distances.x[distances.x > 0])
  distances.y <- diff(sort(as.numeric(state$data$y)))
  min.dist.y <- min(distances.y[distances.y > 0])  
  grid.rect(state$data$x,
            state$data$y,
            min.dist.x,
            min.dist.y,
            just = just,
            hjust = hjust, 
            vjust = vjust,
            default.units = "native",
            gp = gpar(lwd = lwd, lty = lty,
              fill = .match.scale(color, state$data$color, state$scales), 
              col = .match.scale(border, state$data$border, state$scales, type="border")))         
}


jjplot.geom.area <- function(state,
                             alpha = NULL,
                             color = NULL,
                             border = NULL) {
  if (is.null(state$data$color) || !is.null(color)) {
    grid.polygon(c(state$data$x[1], state$data$x, state$data$x[length(state$data$x)]),
                 c(0, state$data$y, 0),
                 default.units = "native",
                 gp = gpar(fill = .match.scale(color, state$data$color, state$scales), 
                   col = .match.scale(border, state$data$border, state$scales, type = "border"),
                   alpha = .match.scale(alpha, state$data$alpha, state$scales, type = "alpha")))
  } else {
    by(state$data, state$data$color, function(xx)
       grid.polygon(c(xx$x[1], xx$x, xx$x[length(xx$x)]),
                 c(0, xx$y, 0),
                 default.units = "native",
                 gp = gpar(fill = .match.scale(color, xx$color, state$scales), 
                   col = .match.scale(border, xx$border, state$scales, type = "border"),
                   alpha = .match.scale(alpha, state$data$alpha, state$scales, type = "alpha"))))
  }
}
  
jjplot.geom.point <- function(state,
                              alpha = NULL,
                              shape = NULL,
                              color = NULL,
                              border = NULL,
                              size = NULL) {
  if (nrow(state$data) == 0) {
    return(NULL)
  }
  alphas <- .match.scale(alpha, state$data$alpha, state$scales, type="alpha")

  dd <- state$data
  if (!all(alphas == alphas[1])) {
    dd <- dd[order(alphas),]
    alphas <- alphas[order(alphas)]
  }

  if (!is.null(shape) && shape %in% c(21, 22)) {
    colors <- .match.scale(border, dd$border, state$scales, type="border")
    fills <- .match.scale(color, dd$color, state$scales)
  } else {
    colors <- .match.scale(color, dd$color, state$scales)
    fills <- NA
  }

  grid.points(dd$x,
              dd$y,
              pch = .match.scale(shape, dd$shape, state$scales, type="shape"),
              size = unit(0.5 * .match.scale(size, dd$size, state$scales, type="size"), "char"),
              gp = gpar(alpha = alphas,
##                cex = 0.33*.match.scale(size, state$data$size, state$scales, type="size"),
                col = colors, fill = fills))
}


jjplot.geom.map <- function(state, database) {
  require(maps)
  regions <- map(database, plot = F)
  grid.lines(regions$x, regions$y,
             default.units = "native")
}

jjplot.geom.abline <- function(state,
                               a = NULL, b = NULL,
                               lwd = 1.5, color = NULL, lty = "solid") {
  ## Find limits
  xlim <- convertX(unit(c(0, 1), "npc"), "native", valueOnly = TRUE)
  ylim <- convertY(unit(c(0, 1), "npc"), "native", valueOnly = TRUE)      

  if (is.null(a)) {
    a <- state$data$a
  }
  if (is.null(b)) {
    b <- state$data$b
  }
  
  ystart <- xlim[1] * a + b
  yend <- xlim[2] * a + b
  
  xstart <- ifelse(a < 0,
                   (ylim[2] - b) / a,
                   (ylim[1] - b) / a)
  xend <- ifelse(a < 0,
                 (ylim[1] - b) / a,
                 (ylim[2] - b) / a)
  
  ## Invariant: xstart <= xend,
  ## So that left hand coordinate should be xtart or xlim[1]
  ## and right hand should be xend or xlim[2].      
  
  ystart <- ifelse(xstart < xlim[1],
                   ystart,
                   ifelse(a < 0,
                          ylim[2],
                          ylim[1]))
  
  yend <- ifelse(xend > xlim[2],
                 yend,
                 ifelse(a < 0,
                        ylim[1],
                        ylim[2]))
  
  xstart <- pmax(xstart, xlim[1])
  xend <- pmin(xend, xlim[2])
  
  grid.segments(xstart, ystart, xend, yend,
                default.units = "native",
                gp = gpar(lwd = lwd,
                  lty = lty,
                  col = .match.scale(color, state$data$color, state$scales)))
}
    
jjplot.geom.hline <- function(state,
                              manual.y = NULL,
                              lwd = 1.5, color = NULL, lty = "solid") {
  y <- if (is.null(manual.y)) state$data$y else manual.y
  for (ii in 1:length(y)) {
    grid.lines(y = y[ii],
               default.units = "native",
               gp = gpar(col = .match.scale(color[ii], state$data$color[ii], state$scales),
                 lwd = lwd,
                 lty = lty))
  }
}    

jjplot.geom.vline <- function(state,
                              manual.x = NULL,
                              lwd = 1.5, color = NULL, lty = "solid") {
  x <- if (is.null(manual.x)) state$data$x else manual.x
  for (ii in 1:length(x)) {
    grid.lines(x = x[ii],
               default.units = "native",
               gp = gpar(col = .match.scale(color[ii], state$data$color[ii], state$scales),
                 lwd = lwd,
                 lty = lty))
  }
}

jjplot.geom.text <- function(state,
                             label = NULL, color = NULL,
                             size = NULL,
                             x = NULL, y = NULL,
                             cex.multiplier = 1.0,
                             hjust = 0.5,
                             vjust = 0.5) {
  if (is.null(x)) {
    x <- state$data$x
  }
  if (is.null(y)) {
    y <- state$data$y
  }
  label <- eval(match.call()$label, state$data)
  if (is.null(label)) {
    label <- state$data$label
  }
  grid.text(label = label,
            x = x, y = y, 
            hjust = hjust, vjust = vjust,
                default.unit = "native",
            gp = gpar(col = .match.scale(color, state$data$color, state$scales),
              cex = cex.multiplier * .match.scale(size, state$data$size, state$scales, type="size")))
}

jjplot.geom.legend <- function(state,
                               x, y,
                               cex.multiplier = 1.0,
                               interline.spacing = 1.5,
                               hjust = 0.5,
                               vjust = 0.5,
                               lwd = 1, lty = "solid") {

  colors <- unique(state$data$color)
  x <- rep(x, length(colors))

  ## Compute the width of the colors.
  text.width <- sapply(as.character(colors),
                       function(z) convertWidth(unit(1, "strwidth", z), "native"))
  text.width <- max(text.width)

  text.height <- sapply(as.character(colors),
                        function(z) convertHeight(unit(1, "strheight", z), "native"))

  text.height <- cumsum(text.height * interline.spacing)
  total.height <- text.height[length(text.height)]

  y <- y + c(0, text.height[-length(text.height)])

  expand <- 1.2
  
  grid.rect(x[1],
            (y[1] + y[length(y)]) / 2,
            text.width * expand,
            total.height * expand,
            hjust = hjust, 
            vjust = vjust,
            default.units = "native",
            gp = gpar(lwd = lwd, lty = lty,
              fill = "white",
              col = "black"))
  
  grid.text(label = as.character(colors),
            x = x, y = y, 
            hjust = hjust, vjust = vjust,
                default.unit = "native",
            gp = gpar(col = .match.scale(colors, state$data$color, state$scales),
              cex = cex.multiplier))
}

jjplot.geom.curve <- function(state,
                              xend, yend,
                              alpha = NULL,
                              color = NULL,
                              lty = "solid",
                              lwd = NULL,
                              curvature = 1,
                              angle = 90) {
  grid.curve(state$data$x,
             state$data$y,
             eval(match.call()$xend, state$data),
             eval(match.call()$yend, state$data),
             curvature = curvature,
             angle = angle,
             square = F,
             default.unit = "native",
             gp = gpar(lty = lty,
               lwd = 2 * .match.scale(lwd, state$data$size, state$scales, type="size"),
               alpha = .match.scale(alpha, state$data$alpha, state$scales, type="alpha"),
               col = .match.scale(color, state$dat$color, state$scales)))
}
                         


jjplot.geom.box <- function(state,
                            color = NULL, border = NULL, width = 0.5,
                            lwd = 1.5, lty = "solid") {
  temp.data <- data.frame(x = subset(state$data, .quantile == 0)$x,
                          quantile.0 = subset(state$data, .quantile == 0)$y,
                          quantile.25 = subset(state$data, .quantile == 25)$y,
                          quantile.50 = subset(state$data, .quantile == 50)$y,
                          quantile.75 = subset(state$data, .quantile == 75)$y,
                          quantile.100 = subset(state$data, .quantile == 100)$y)
  if (!is.null(state$data$color)) {
    temp.data$color <- subset(state$data, .quantile == 0)$color
  }
  if (!is.null(state$data$border)) {
    temp.data$border <- subset(state$data, .quantile == 0)$border
  }
  grid.rect(as.numeric(temp.data$x),
            temp.data$quantile.25,
            width,
            temp.data$quantile.75 - temp.data$quantile.25,
            default.units = "native",
            just = c("center", "bottom"),
            gp = gpar(lwd = lwd,
              lty = lty,
              fill = .match.scale(color, temp.data$color, state$scales),
              col = .match.scale(border, temp.data$border, state$scales, type = "border")))
  
  grid.segments(c(temp.data$x, temp.data$x, as.numeric(temp.data$x) - width / 2),
                c(temp.data$quantile.0, temp.data$quantile.100, temp.data$quantile.50),
                c(temp.data$x, temp.data$x, as.numeric(temp.data$x) + width / 2),
                c(temp.data$quantile.25, temp.data$quantile.75, temp.data$quantile.50),
                default.units = "native",
                gp = gpar(lwd = lwd,
                      lty = lty,
                  col = .match.scale(border, temp.data$border, state$scales, type = "border")))
}

.jjplot.expand.bar <- function(state,
                               width = 1.0,
                               horizontal = FALSE,
                               color = NULL) {
  ## FIXME
  ##  xlim <- range(as.numeric(layer.data$x))
  ##  x.padding <- (xlim[2] - xlim[1]) * eval.expand[1]
  ##  if (x.padding >= width / 2) {
  ##    list(x = c(xlim[1] - width / 2 + x.padding,
  ##           xlim[2] + width / 2 - x.padding), y = 0)
  ##  } else {
  if (horizontal) {
    list(x = 0)
  } else {
    list(y = 0,
         x = c(min(as.numeric(state$data$x)) - width,
           max(as.numeric(state$data$x)) + width))
  }
  ##  }
}

.jjplot.expand.box <- function(state, width = 0.5, ...) {
  list(x = c(min(as.numeric(state$data$x)) - width / 2, max(as.numeric(state$data$x)) + width / 2))
}        

.jjplot.expand.area <- function(state, ...) {
  list(y = 0)
}

.jjplot.expand.map <- function(state, database) {
  require(maps)
  regions <- map(database, plot = F)
  list(x = range(regions$x, na.rm = T),
       y = range(regions$y, na.rm = T))
}


.jjplot.expand.tile <- function(state,
                                ...) {
  distances.x <- diff(sort(as.numeric(state$data$x)))
  min.dist.x <- min(distances.x[distances.x > 0])
  distances.y <- diff(sort(as.numeric(state$data$y)))
  min.dist.y <- min(distances.y[distances.y > 0])  
  
  list(x = c(min(as.numeric(state$data$x)) - min.dist.x,
             max(as.numeric(state$data$x)) + min.dist.x),
       y = c(min(as.numeric(state$data$y)) - min.dist.y,
             max(as.numeric(state$data$y)) + min.dist.y))
}

