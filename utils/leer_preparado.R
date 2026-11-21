# Grupo 20 | Una funcion auxiliar por archivo.
leer_preparado <- function() {
  destino <- 'input/listings_preparado.csv'
  if (!file.exists(destino)) stop('Falta input/listings_preparado.csv. Ejecuta primero script/01_preparacion.R')
  read.csv(destino, colClasses=c(id='character',host_id='character'),
           stringsAsFactors=FALSE,check.names=FALSE)
}
