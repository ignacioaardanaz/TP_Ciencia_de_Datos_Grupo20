# Grupo 20 | Una funcion auxiliar por archivo.
preparar_carpetas <- function() {
  for (p in c('input', 'output/tablas', 'output/graficos')) {
    if (!dir.exists(p)) dir.create(p, recursive=TRUE, showWarnings=FALSE)
  }
}
