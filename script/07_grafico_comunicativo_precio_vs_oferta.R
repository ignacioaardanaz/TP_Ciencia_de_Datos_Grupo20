# ============================================================================
# REPLICA DEL GRAFICO DE BURBUJAS DE LA IMAGEN DE REFERENCIA
# Requiere solamente: ggplot2
# Los datos son los 8 valores de EJEMPLO del codigo provisto, NO una lectura
# automatica de Inside Airbnb. La fecha y la fuente se conservan para replicar
# visualmente la imagen; para un TP, verificar y sustituir con datos reales.
# ============================================================================

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2)

# 1. Datos exactamente iguales a los del grafico de referencia.
datos <- data.frame(
  barrio = c("Palermo", "Puerto Madero", "Recoleta", "Belgrano",
             "San Telmo", "Colegiales", "Villa Crespo", "Almagro"),
  precio_tipico = c(108500, 180400, 101200, 105000,
                    89500, 96000, 86000, 82000),
  avisos_activos = c(8200, 1800, 4800, 2900,
                     2400, 1850, 1600, 1350),
  movimiento_estimado = c(950, 240, 520, 340, 280, 190, 210, 160),
  destacado = c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

# 2. Posiciones MANUALES: la imagen se reproduce sin que ggrepel mueva textos.
# hjust 0: texto hacia la derecha; hjust 1: texto hacia la izquierda.
posiciones <- data.frame(
  barrio = c("Palermo", "Puerto Madero", "Recoleta", "Belgrano",
             "San Telmo", "Colegiales", "Villa Crespo", "Almagro"),
  x_etiqueta = c(117000, 185900, 106700, 110100,
                 84000, 96700, 80000, 78200),
  y_etiqueta = c(8200, 1710, 4770, 3190,
                 2460, 1810, 1640, 1130),
  hjust = c(0, 0, 0, 0, 1, 0, 1, 1),
  stringsAsFactors = FALSE
)
datos <- merge(datos, posiciones, by = "barrio", sort = FALSE)

# Diametros en mm, ajustados para que cada burbuja copie la imagen.
datos$diametro_mm <- c(
  "Palermo" = 20.0, "Puerto Madero" = 11.0,
  "Recoleta" = 11.7, "Belgrano" = 9.6,
  "San Telmo" = 10.0, "Colegiales" = 9.1,
  "Villa Crespo" = 8.0, "Almagro" = 7.5
)[datos$barrio]

# 3. Colores, fuentes y formato de salida.
FONDO <- "#FAF7F2"
NARANJA <- "#DF5C25"
GRIS <- "#8E9BA8"
OSCURO <- "#1F2428"
SUAVE <- "#595F66"
GRILLA <- "#E3DED7"

# En Windows, serif suele ser Times New Roman y sans suele ser Arial.
# Para aproximar aun mas la portada, se puede probar familia_titulo <- "Georgia"
# si esa fuente esta registrada en el dispositivo grafico de R.
familia_titulo <- "serif"
familia_texto <- "sans"

# 4. Grafico principal.
grafico <- ggplot(datos, aes(x = precio_tipico, y = avisos_activos)) +
  # Cuadricula punteada de la imagen.
  geom_hline(yintercept = seq(0, 10000, 2000),
             colour = GRILLA, linetype = "dashed", linewidth = 0.38) +
  geom_vline(xintercept = seq(50000, 250000, 50000),
             colour = GRILLA, linetype = "dashed", linewidth = 0.38) +

  # Burbujas: diametro manual y color segun el destacado.
  geom_point(aes(size = diametro_mm, fill = destacado),
             shape = 21, colour = "#F8F5F0", stroke = 0.45, alpha = 0.98) +
  scale_size_identity(guide = "none") +
  scale_fill_manual(values = c("FALSE" = GRIS, "TRUE" = NARANJA),
                    guide = "none") +

  # Etiquetas de barrios, con posicion fija (reproducible).
  geom_text(data = subset(datos, !destacado),
            aes(x = x_etiqueta, y = y_etiqueta, label = barrio, hjust = hjust),
            inherit.aes = FALSE, colour = OSCURO, size = 4.0,
            family = familia_texto) +
  geom_text(data = subset(datos, destacado),
            aes(x = x_etiqueta, y = y_etiqueta, label = barrio, hjust = hjust),
            inherit.aes = FALSE, colour = OSCURO, size = 4.1,
            fontface = "bold", family = familia_texto) +

  # Flecha/linea y comentario que apuntan a Palermo.
  annotate("segment", x = 120000, y = 9170,
           xend = 113200, yend = 8540,
           colour = SUAVE, linewidth = 0.45) +
  annotate("point", x = 113200, y = 8540,
           colour = SUAVE, size = 0.9) +
  annotate("text", x = 121300, y = 9220,
           label = "Mayor volumen y\nrotación de huéspedes",
           hjust = 0, vjust = 0.5, size = 3.4, lineheight = 1.0,
           family = familia_texto, colour = OSCURO) +

  # Leyenda DIBUJADA A MANO para conservar posicion, textos y tamaños.
  annotate("rect", xmin = 194600, xmax = 249000,
           ymin = 8070, ymax = 9825, fill = FONDO,
           colour = "#D5D1CB", linewidth = 0.48) +
  annotate("text", x = 221900, y = 9440,
           label = "Tamaño de burbuja:\nMovimiento estimado (reseñas/reservas)",
           family = familia_texto, colour = OSCURO,
           size = 3.45, lineheight = 1.06) +
  annotate("point", x = 206300, y = 8540, shape = 21,
           size = 4.3, fill = "#AAAAAA", colour = "#AAAAAA") +
  annotate("point", x = 226900, y = 8540, shape = 21,
           size = 8.0, fill = "#AAAAAA", colour = "#AAAAAA") +
  annotate("text", x = 211200, y = 8540, label = "Menor",
           hjust = 0, vjust = 0.5, colour = OSCURO,
           size = 3.5, family = familia_texto) +
  annotate("text", x = 232500, y = 8540, label = "Mayor",
           hjust = 0, vjust = 0.5, colour = OSCURO,
           size = 3.5, family = familia_texto) +

  # Escalas: mismos limites y marcas de ejes que la imagen.
  scale_x_continuous(
    limits = c(50000, 250000),
    breaks = seq(50000, 250000, 50000),
    labels = c("$50 mil", "$100 mil", "$150 mil", "$200 mil", "$250 mil"),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(0, 10000),
    breaks = seq(0, 10000, 2000),
    labels = c("0", "2.000", "4.000", "6.000", "8.000", "10.000"),
    expand = expansion(mult = 0)
  ) +

  labs(
    title = "Puerto Madero lidera en precios, pero Palermo concentra el negocio",
    subtitle = paste0(
      "Precio típico por noche, cantidad de avisos activos y movimiento estimado ",
      "en CABA (hasta el 23 de septiembre de 2026)"
    ),
    x = "Precio típico por noche (ARS)",
    y = "Cantidad de avisos activos",
    caption = "Fuente: Inside Airbnb Buenos Aires (datos hasta el 23 de septiembre de 2026)"
  ) +
  theme_minimal(base_size = 12, base_family = familia_texto) +
  theme(
    plot.background = element_rect(fill = FONDO, colour = NA),
    panel.background = element_rect(fill = FONDO, colour = NA),
    panel.grid = element_blank(),
    axis.line.x = element_line(colour = "#777777", linewidth = 0.65),
    axis.line.y = element_line(colour = "#777777", linewidth = 0.65),
    axis.ticks.x = element_line(colour = "#777777", linewidth = 0.5),
    axis.ticks.y = element_line(colour = "#777777", linewidth = 0.5),
    axis.ticks.length = grid::unit(0.13, "cm"),
    axis.title = element_text(colour = OSCURO, size = 11.2),
    axis.title.x = element_text(margin = margin(t = 9)),
    axis.title.y = element_text(margin = margin(r = 10)),
    axis.text = element_text(colour = OSCURO, size = 10),
    plot.title = element_text(
      colour = OSCURO, family = familia_titulo, face = "bold",
      size = 21, margin = margin(b = 5)
    ),
    plot.subtitle = element_text(
      colour = SUAVE, size = 10.9, margin = margin(b = 22)
    ),
    plot.caption = element_text(
      colour = "#73777C", size = 8.3, hjust = 0,
      margin = margin(t = 18)
    ),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.margin = margin(t = 17, r = 30, b = 0, l = 42, unit = "pt")
  )

# 5. Mostrar y guardar. Se guarda en el directorio actual (getwd()).
print(grafico)

ggsave(
  filename = "airbnb_caba_replica.png", plot = grafico,
  width = 12.67, height = 6.96, units = "in", dpi = 100, bg = FONDO
)

ggsave(
  filename = "airbnb_caba_replica_alta_calidad.jpg", plot = grafico,
  width = 12.67, height = 6.96, units = "in", dpi = 300,
  quality = 95, bg = FONDO
)

cat("Archivos guardados en:", normalizePath(getwd()), "\n")
