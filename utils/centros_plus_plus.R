# Grupo 20 | Funcion auxiliar extraida sin modificar su logica.
centros_plus_plus <- function(x, k) {
  n <- nrow(x)
  p <- ncol(x)
  elegidos <- integer(k)
  elegidos[1] <- sample.int(n, 1)
  dist2 <- rowSums((x - matrix(x[elegidos[1], ], nrow = n, ncol = p,
                                  byrow = TRUE))^2)
  if (k > 1) {
    for (j in 2:k) {
      pesos <- dist2
      pesos[elegidos[seq_len(j - 1)]] <- 0
      if (sum(pesos) == 0) {
        elegidos[j] <- sample(setdiff(seq_len(n), elegidos[seq_len(j - 1)]), 1)
      } else {
        elegidos[j] <- sample.int(n, 1, prob = pesos)
      }
      d_new <- rowSums((x - matrix(x[elegidos[j], ], nrow = n, ncol = p,
                                    byrow = TRUE))^2)
      dist2 <- pmin(dist2, d_new)
    }
  }
  x[elegidos, , drop = FALSE]
}
