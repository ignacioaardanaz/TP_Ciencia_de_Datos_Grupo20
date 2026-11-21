# Grupo 20 | Funcion auxiliar extraida sin modificar su logica.
fmt <- function(x) format(round(x), big.mark = ".", decimal.mark = ",",
                          trim = TRUE, scientific = FALSE)
