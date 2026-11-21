# 04 - K-MEANS SOBRE ANFITRIONES (MODELO NATIVO R)
# Nota: el resultado EXACTO anterior se calculo con Python; esta es una
# reproduccion metodologica en R que se debe cotejar antes de actualizar la PPT.
source('utils/funciones_comunes.R',encoding='UTF-8')
verificar_raiz(); preparar_carpetas(); verificar_paquetes(c('cluster'))
set.seed(42)
a <- leer_preparado()
vars <- c('id','host_id','availability_365','number_of_reviews')
if (anyNA(a[vars])) stop('Existen nulos en variables para clustering.')
datos <- a[,vars]
stopifnot(!anyDuplicated(datos$id))
n_anuncios <- nrow(datos)
n_hosts <- length(unique(datos$host_id))
cat('Anuncios:',n_anuncios,'| Anfitriones:',n_hosts,'\n')
# 2. AGREGACION POR ANFITRION -------------------------------------------------
# n_listings = cantidad de anuncios por host_id
# avg_availability = promedio de availability_365 de sus anuncios
# avg_reviews = promedio de number_of_reviews de sus anuncios
conteo <- aggregate(id ~ host_id, datos, function(x) length(unique(x)))
names(conteo)[2] <- "n_listings"
promedios <- aggregate(
  cbind(availability_365, number_of_reviews) ~ host_id,
  data = datos, FUN = mean
)
names(promedios)[2:3] <- c("avg_availability", "avg_reviews")
hosts <- merge(conteo, promedios, by = "host_id", sort = TRUE)
stopifnot(sum(hosts$n_listings) == n_anuncios)

# 3. WINSORIZACION Y ESTANDARIZACION -----------------------------------------
# Se limita la cantidad de anuncios SOLO para calcular los clusters.
# Para el resumen de stock se usa n_listings ORIGINAL, sin winsorizar.
p99 <- as.numeric(quantile(hosts$n_listings, probs = 0.99, type = 7))
cat("Percentil 99 de n_listings:", p99, "\n")
hosts$n_listings_winsor <- pmin(hosts$n_listings, p99)
cat("Anfitriones afectados por winsorizacion:", sum(hosts$n_listings > p99), "\n")
matriz <- cbind(
  n_listings = hosts$n_listings_winsor,
  avg_availability = hosts$avg_availability,
  avg_reviews = hosts$avg_reviews
)

# StandardScaler (Python) usa desvio poblacional, divisor n.
medias <- colMeans(matriz)
desvios <- sqrt(colMeans(sweep(matriz, 2, medias, "-")^2))
if (any(desvios == 0)) stop("Existe alguna variable constante.")
X <- sweep(sweep(matriz, 2, medias, "-"), 2, desvios, "/")

# 4. INICIALIZACION K-MEANS++ Y 20 INICIOS -----------------------------------
# stats::kmeans() admite centroides iniciales. Los creamos con K-means++.
# Este es el metodo nativo R mas proximo a scikit-learn usado en las diapositivas.
# Las funciones centros_plus_plus y ajustar_kmeans se cargan desde utils/.

# 5. COMPARACION DEL NUMERO DE CLUSTERS --------------------------------------
# Silueta sobre una muestra de 1.200 anfitriones para evitar una matriz de
# distancias de mas de 14.000 x 14.000 (costosa en memoria).
set.seed(42)
ids_silueta <- sample.int(nrow(X), min(1200, nrow(X)))
dist_silueta <- dist(X[ids_silueta, , drop = FALSE])

modelos <- vector("list", 5)
seleccion_k <- data.frame(k = 2:6, inertia = NA_real_, silhouette = NA_real_)
for (i in seq_along(modelos)) {
  k <- seleccion_k$k[i]
  m <- ajustar_kmeans(X, k, n_init = 20, max_iter = 300)
  sil <- cluster::silhouette(m$cluster[ids_silueta], dist_silueta)
  modelos[[i]] <- m
  seleccion_k$inertia[i] <- m$tot.withinss
  seleccion_k$silhouette[i] <- mean(sil[, "sil_width"])
}
cat("\nComparacion de k:\n")
print(seleccion_k, row.names = FALSE, digits = 5)
cat("Mejor k segun silueta calculada en R:",
    seleccion_k$k[which.max(seleccion_k$silhouette)], "\n")

# Las diapositivas corregidas utilizan 4 clusters, con la seleccion realizada
# en Python (silueta = 0,485 para k=4 en su muestra aleatoria).
# El k que maximiza silueta en R podria diferir por la inicializacion/muestra.
k_elegido <- 4
modelo <- modelos[[which(seleccion_k$k == k_elegido)]]
hosts$cluster_raw <- modelo$cluster

# 6. ASIGNAR ETIQUETAS INTERPRETABLES -----------------------------------------
# Equivalente al criterio del script original, NO arbitrario por numero bruto.
perfil <- aggregate(
  hosts[, c("n_listings", "avg_availability", "avg_reviews")],
  by = list(cluster_raw = hosts$cluster_raw), FUN = mean
)
id_multi <- perfil$cluster_raw[which.max(perfil$n_listings)]
restante <- perfil[perfil$cluster_raw != id_multi, ]
id_reviews <- restante$cluster_raw[which.max(restante$avg_reviews)]
restante <- restante[restante$cluster_raw != id_reviews, ]
id_low <- restante$cluster_raw[which.min(restante$avg_availability)]
id_high <- restante$cluster_raw[which.max(restante$avg_availability)]

mapa <- setNames(c(1L, 2L, 3L, 4L),
                 as.character(c(id_low, id_high, id_reviews, id_multi)))
hosts$cluster <- unname(mapa[as.character(hosts$cluster_raw)])
etiquetas <- c("Baja disponibilidad", "Alta disponibilidad",
               "Alta trayectoria de reseñas", "Multipublicación")

# 7. RESUMEN: STOCK REAL, SIN WINSORIZAR --------------------------------------
resumen <- do.call(rbind, lapply(1:4, function(i) {
  grupo <- hosts[hosts$cluster == i, , drop = FALSE]
  data.frame(
    cluster = i,
    hosts = nrow(grupo),
    listings = sum(grupo$n_listings),
    avg_listings = mean(grupo$n_listings), # PROMEDIO REAL
    avg_listings_winsor = mean(grupo$n_listings_winsor), # PROMEDIO PARA K-MEANS
    hosts_winsorizados = sum(grupo$n_listings > p99),
    median_listings = median(grupo$n_listings),
    avg_availability = mean(grupo$avg_availability),
    avg_reviews = mean(grupo$avg_reviews),
    min_listings = min(grupo$n_listings),
    max_listings = max(grupo$n_listings),
    label = etiquetas[i],
    share_hosts = 100 * nrow(grupo) / n_hosts,
    share_stock = 100 * sum(grupo$n_listings) / n_anuncios
  )
}))

stopifnot(all(resumen$avg_listings_winsor <= p99))
stopifnot(sum(resumen$hosts_winsorizados) == sum(hosts$n_listings > p99))
stopifnot(sum(resumen$hosts) == n_hosts)
stopifnot(sum(resumen$listings) == n_anuncios)
stopifnot(abs(sum(resumen$share_hosts) - 100) < 1e-8)
stopifnot(abs(sum(resumen$share_stock) - 100) < 1e-8)

cat("\nLa tabla distingue avg_listings (real) de avg_listings_winsor (recortado a 18).\n")
cat("Revisar que los promedios por grupos no se interpreten como la misma variable.\n")
cat("\nResumen de los 4 clusters (calculado en R):\n")
print(resumen, row.names = FALSE, digits = 5)

# 8. EXPORTAR ARCHIVOS --------------------------------------------------------
write.csv(resumen, "output/tablas/04_clusters_resumen.csv", row.names = FALSE)
write.csv(hosts[, c("host_id", "n_listings", "avg_availability",
                    "avg_reviews", "cluster")],
          "output/tablas/04_clusters_asignaciones.csv", row.names = FALSE)
write.csv(seleccion_k, "output/tablas/04_clusters_seleccion_k.csv", row.names = FALSE)

# 9. GRAFICOS DE APOYO ---------------------------------------------------------
png("output/graficos/04_silueta_R.png", width = 22, height = 14, units = "cm", res = 300)
plot(seleccion_k$k, seleccion_k$silhouette, type = "b", pch = 19,
     xlab = "Numero de clusters (k)", ylab = "Silueta media",
     main = "Seleccion de k por coeficiente de silueta")
abline(v = k_elegido, lty = 2)
dev.off()

png("output/graficos/04_participacion_stock_R.png", width = 22, height = 14, units = "cm", res = 300)
barplot(rbind(resumen$share_hosts, resumen$share_stock), beside = TRUE,
        names.arg = etiquetas, las = 2,
        legend.text = c("% de anfitriones", "% de publicaciones"),
        ylab = "Porcentaje", main = "Participacion por perfil de anfitrion")
dev.off()

cat("\nArchivos exportados en:", normalizePath(getwd()), "\n")
cat("ATENCION: contraste el resumen R con los resultados originales en Python.\n")
