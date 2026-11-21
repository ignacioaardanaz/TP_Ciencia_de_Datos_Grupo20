# GRUPO 20 - utilidades compartidas (R base)
verificar_raiz <- function() {
  necesarios <- c('raw', 'input', 'output', 'script', 'utils')
  if (!all(dir.exists(necesarios))) {
    stop('No estas en la carpeta principal proyecto/. Abri proyecto.Rproj o usa Session > Set Working Directory > Choose Directory.')
  }
}
preparar_carpetas <- function() {
  for (p in c('input', 'output/tablas', 'output/graficos')) {
    if (!dir.exists(p)) dir.create(p, recursive=TRUE, showWarnings=FALSE)
  }
}
verificar_paquetes <- function(paquetes) {
  falta <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly=TRUE)]
  if (length(falta)) stop(paste0('Instala los paquetes primero: install.packages(c(',
                      paste(sprintf('"%s"',falta), collapse=','), '))'))
}
leer_preparado <- function() {
  destino <- 'input/listings_preparado.csv'
  if (!file.exists(destino)) stop('Falta input/listings_preparado.csv. Ejecuta primero script/01_preparacion.R')
  read.csv(destino, colClasses=c(id='character',host_id='character'),
           stringsAsFactors=FALSE,check.names=FALSE)
}
formato_ars <- function(x) paste0('$',format(round(x),big.mark='.',decimal.mark=',',trim=TRUE,scientific=FALSE))
formato_entero <- function(x) format(x,big.mark='.',decimal.mark=',',trim=TRUE,scientific=FALSE)
