# Grupo 20 | Una funcion auxiliar por archivo.
verificar_raiz <- function() {
  necesarios <- c('raw', 'input', 'output', 'script', 'utils')
  if (!all(dir.exists(necesarios))) {
    stop('No estas en la carpeta principal proyecto/. Abri proyecto.Rproj o usa Session > Set Working Directory > Choose Directory.')
  }
}
