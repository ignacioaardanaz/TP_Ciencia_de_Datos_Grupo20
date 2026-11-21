# Grupo 20 | Funcion auxiliar extraida sin modificar su logica.
ajustar_kmeans <- function(x, k, n_init = 20, max_iter = 300) {
  mejor <- NULL
  for (iteracion in seq_len(n_init)) {
    iniciales <- centros_plus_plus(x, k)
    mod <- stats::kmeans(x, centers = iniciales,
                         iter.max = max_iter, algorithm = "Lloyd")
    if (is.null(mejor) || mod$tot.withinss < mejor$tot.withinss) {
      mejor <- mod
    }
  }
  mejor
}
