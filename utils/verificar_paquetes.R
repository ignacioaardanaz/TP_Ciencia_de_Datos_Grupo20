# Grupo 20 | Una funcion auxiliar por archivo.
verificar_paquetes <- function(paquetes) {
  falta <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly=TRUE)]
  if (length(falta)) stop(paste0('Instala los paquetes primero: install.packages(c(',
                      paste(sprintf('"%s"',falta), collapse=','), '))'))
}
