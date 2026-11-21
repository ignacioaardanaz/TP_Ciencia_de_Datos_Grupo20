# Grupo 20 | Una funcion auxiliar por archivo.
formato_ars <- function(x) paste0('$',format(round(x),big.mark='.',decimal.mark=',',trim=TRUE,scientific=FALSE))
