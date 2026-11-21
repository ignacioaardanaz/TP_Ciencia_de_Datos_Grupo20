# Grupo 20 | Funcion auxiliar extraida sin modificar su logica.
pct <- function(m, term) if (term %in% names(coef(m))) 100*expm1(coef(m)[[term]]) else NA_real_
