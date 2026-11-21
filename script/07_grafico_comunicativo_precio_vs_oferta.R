# GRUPO 20 | GRAFICO COMUNICATIVO: PRECIO Y OFERTA POR BARRIO
# Fuente: archivos originales de Inside Airbnb, SIN descargas nuevas.
# Muestra: viviendas completas para exactamente 2 huespedes, precio positivo.
# Cada punto: barrio con >= 30 anuncios de esa misma muestra.
# El tamanio del punto NO representa reservas ni facturacion.
# Los registros originales tienen last_scraped del 25 al 27/09/2026:
# NO son un corte verificable al 23/09/2026.

source("utils/funciones_comunes.R", encoding = "UTF-8")
verificar_raiz()
preparar_carpetas()
verificar_paquetes("ggplot2")

# 1. Leer datos PREPARADOS a partir de los archivos originales de raw/.
# El script 01 crea input/listings_preparado.csv sin eliminar precios altos.
a <- leer_preparado()
requeridas <- c("id", "price", "room_type", "accommodates",
                "neighbourhood", "last_scraped")
faltan <- setdiff(requeridas, names(a))
if (length(faltan)) stop("Faltan columnas: ", paste(faltan, collapse = ", "))
if (nrow(a) != 29753L) stop("La base preparada no tiene 29.753 anuncios.")
if (!is.numeric(a$price) || !is.numeric(a$accommodates)) {
  stop("price y accommodates deben ser numericas. Ejecutar script/01_preparacion.R.")
}

# 2. Filtros simetricos: la cantidad y el precio se calculan para el MISMO
# conjunto de publicaciones, sin tomar anuncios de otros tipos o capacidades.
es_valido <- complete.cases(a[, c("price", "room_type", "accommodates", "neighbourhood")]) &
  is.finite(a$price) & a$price > 0 &
  a$room_type == "Entire home/apt" &
  a$accommodates == 2 &
  nzchar(trimws(a$neighbourhood))
es_valido[is.na(es_valido)] <- FALSE
muestra <- a[es_valido, c("id", "neighbourhood", "price"), drop = FALSE]
if (nrow(muestra) == 0L) stop("La muestra quedo vacia: revisar los filtros.")

# 3. Conteo y mediana reales de cada barrio.
grupos <- split(muestra$price, muestra$neighbourhood)
tabla <- data.frame(
  barrio = names(grupos),
  anuncios = vapply(grupos, length, integer(1)),
  precio_mediano = vapply(grupos, stats::median, numeric(1)),
  stringsAsFactors = FALSE
)
tabla <- tabla[order(-tabla$anuncios, tabla$barrio), , drop = FALSE]
rownames(tabla) <- NULL
tabla$incluido_en_grafico <- tabla$anuncios >= 30L

foco <- c("Palermo", "Puerto Madero")
contexto <- c("Recoleta", "Belgrano", "Villa Crespo", "San Telmo")
etiquetados <- c(foco, contexto)
if (!all(etiquetados %in% tabla$barrio[tabla$incluido_en_grafico])) {
  stop("Falta algun barrio destacado o tiene menos de 30 anuncios.")
}
tabla$etiquetado <- tabla$barrio %in% etiquetados
write.csv(tabla, "output/tablas/07_precio_oferta_por_barrio.csv",
          row.names = FALSE, fileEncoding = "UTF-8")

mostrar <- tabla[tabla$incluido_en_grafico, , drop = FALSE]
mostrar$categoria <- ifelse(mostrar$barrio %in% foco, "Protagonistas",
                     ifelse(mostrar$barrio %in% contexto,
                            "Barrios de referencia", "Otros barrios"))

# 4. Mensaje: generado por calculo, nunca introduciendo valores de ejemplo.
palermo <- tabla[tabla$barrio == "Palermo", , drop = FALSE]
puerto <- tabla[tabla$barrio == "Puerto Madero", , drop = FALSE]
diferencia_pct <- 100 * (puerto$precio_mediano / palermo$precio_mediano - 1)
relacion_anuncios <- palermo$anuncios / puerto$anuncios
# La funcion fmt se carga desde utils/funciones_comunes.R.


# Verificar las fechas efectivas de la fuente y no atribuir un corte falso.
fechas <- as.Date(a$last_scraped)
if (!length(fechas) || anyNA(fechas)) stop("Fechas last_scraped invalidas.")
rango_fecha <- paste(format(min(fechas), "%d/%m/%Y"),
                    format(max(fechas), "%d/%m/%Y"), sep = " al ")

# 5. Ubicacion explicita de las seis etiquetas para evitar superposiciones.
# Estas coordenadas se eligieron a partir de la muestra original del Grupo 20.
pos <- data.frame(
  barrio = c("Palermo", "Puerto Madero", "Recoleta", "Belgrano",
             "Villa Crespo", "San Telmo"),
  x_etiqueta = c(131000, 147000, 122000, 122000, 60500, 60500),
  y_etiqueta = c(4430, 720, 2150, 1330, 1430, 700),
  stringsAsFactors = FALSE
)
lab <- merge(pos, mostrar[, c("barrio", "anuncios", "precio_mediano", "categoria")],
             by = "barrio", sort = FALSE)
lab <- lab[match(pos$barrio, lab$barrio), , drop = FALSE]
lab$etiqueta <- paste0(toupper(lab$barrio), "\n",
                      fmt(lab$anuncios), " anuncios | $", fmt(lab$precio_mediano))

# 6. Grafico comunicativo: todos los puntos del mismo tamanio por categoria.
# Los colores distinguen dos casos centrales, cuatro de contexto y el resto.
fondo <- "#FAF8F4"
tinta <- "#20313B"
gris <- "#A7B0B6"
azul <- "#406A84"
naranja <- "#E46A32"
paleta <- c("Protagonistas" = naranja, "Barrios de referencia" = azul,
            "Otros barrios" = gris)

p <- ggplot2::ggplot(mostrar, ggplot2::aes(x = precio_mediano, y = anuncios)) +
  ggplot2::geom_point(
    data = mostrar[mostrar$categoria == "Otros barrios", , drop = FALSE],
    color = gris, size = 3.5, alpha = 0.75) +
  ggplot2::geom_point(
    data = mostrar[mostrar$categoria == "Barrios de referencia", , drop = FALSE],
    color = azul, size = 5.2) +
  ggplot2::geom_point(
    data = mostrar[mostrar$categoria == "Protagonistas", , drop = FALSE],
    color = naranja, size = 6.9) +
  ggplot2::geom_segment(
    data = lab,
    mapping = ggplot2::aes(x = precio_mediano, y = anuncios,
                           xend = x_etiqueta, yend = y_etiqueta,
                           color = categoria),
    inherit.aes = FALSE, linewidth = 0.6) +
  ggplot2::geom_label(
    data = lab,
    mapping = ggplot2::aes(x = x_etiqueta, y = y_etiqueta,
                           label = etiqueta, color = categoria),
    inherit.aes = FALSE, hjust = 0, vjust = 0.5,
    fill = fondo, size = 3.5, fontface = "bold", lineheight = 1.12,
    label.padding = grid::unit(0.18, "lines"), label.size = 0) +
  ggplot2::scale_color_manual(values = paleta, guide = "none") +
  ggplot2::scale_x_continuous(
    breaks = seq(50000, 200000, by = 25000),
    labels = function(x) paste0("$", fmt(x / 1000), " mil")) +
  ggplot2::scale_y_continuous(
    breaks = seq(0, 5000, by = 1000), labels = fmt) +
  ggplot2::coord_cartesian(xlim = c(50000, 217000),
                           ylim = c(0, 5000), clip = "off") +
  ggplot2::labs(
    title = paste0("Puerto Madero: ", fmt(diferencia_pct),
                   "% mas caro; Palermo: ", fmt(relacion_anuncios),
                   " veces mas anuncios"),
    subtitle = paste0("Viviendas completas para 2 huespedes | ",
                      nrow(mostrar), " barrios con al menos 30 anuncios comparables"),
    x = "Precio mediano publicado por noche (ARS)",
    y = "Cantidad de anuncios comparables",
    caption = paste0("Fuente: Inside Airbnb; archivos originales del Grupo 20. Capturas: ",
                     rango_fecha,
                     ".\nPrecios publicados, no reservas. ",
                     "No es un corte verificado al 23/09/2026.")
  ) +
  ggplot2::theme_minimal(base_size = 14) +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = fondo, color = NA),
    panel.background = ggplot2::element_rect(fill = fondo, color = NA),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_line(color = "#E4E0DA", linewidth = 0.42),
    axis.title = ggplot2::element_text(color = tinta, face = "bold", size = 13),
    axis.text = ggplot2::element_text(color = "#56646E", size = 11),
    plot.title = ggplot2::element_text(color = tinta, face = "bold", size = 20),
    plot.subtitle = ggplot2::element_text(color = "#56646E", size = 12,
                                         margin = ggplot2::margin(b = 18)),
    plot.caption = ggplot2::element_text(color = "#56646E", size = 9, hjust = 0,
                                        lineheight = 1.2,
                                        margin = ggplot2::margin(t = 17)),
    plot.margin = ggplot2::margin(t = 22, r = 25, b = 18, l = 27)
  )

# 7. Unica salida comunicativa oficial: PNG con la misma ruta publicada.
salida <- "output/graficos/grupo_20_comunicativo.png"
ggplot2::ggsave(salida, plot = p, width = 16, height = 9.3,
                units = "in", dpi = 300, bg = fondo)

cat("\nGRAFICO COMUNICATIVO (datos reales de Airbnb)\n")
cat("Muestra:", nrow(muestra), "anuncios | Barrios:", nrow(mostrar), "\n")
for (barrio in etiquetados) {
  z <- tabla[tabla$barrio == barrio, , drop = FALSE]
  cat("  ", barrio, ": ", z$anuncios, " anuncios; mediana $",
      fmt(z$precio_mediano), "\n", sep = "")
}
cat("Salida:", salida, "\n")
cat("Tabla: output/tablas/07_precio_oferta_por_barrio.csv\n")
print(p)
