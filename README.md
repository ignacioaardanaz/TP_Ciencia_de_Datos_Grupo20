# Airbnb en CABA — Grupo 20 (FCE-UBA, 2.º cuatrimestre 2026)

## Objetivo
Estudiar asociaciones entre el **precio publicado** de Airbnb y las características del alojamiento, la concentración geográfica de anuncios y los perfiles de anfitriones. Los análisis son **descriptivos y asociativos, no causales**.

## Base y procedencia
Dos archivos originales, sin alterar, proporcionados por el grupo:
- `raw/listings.csv` (29.753 anuncios y 19 columnas).
- `raw/listings.csv(1).gz` (29.753 anuncios y 90 columnas). Se usa, entre otras, `accommodates` y `last_scraped`.

La **fecha de referencia utilizada históricamente por el grupo** es el **23/09/2026**; esto no significa que el archivo tenga todos los registros capturados exactamente ese día. El campo `last_scraped` contiene fechas 25, 26 y 27/09/2026. No se descargaron archivos actualizados.

En `auxiliar/` se incluyen `neighbourhoods.csv` y `neighbourhoods.geojson`, tal como se recibieron. Los archivos de calendario y reseñas extensas que el grupo había compartido **no son necesarios para ejecutar este proyecto** y no se empaquetan aquí. `reviews.csv.gz` por sí solo supera los 100 MB, máximo de un archivo normal de GitHub; si más adelante lo usan, consideren Git LFS.

## Cómo ejecutar
1. **Descomprimir** este ZIP sin cambiar nombres de archivos ni carpetas.
2. Abrir `proyecto.Rproj` en RStudio o seleccionar **la raíz** `grupo20_proyecto_final_R/` como *working directory* (debe contener `raw/` y `script/`).
3. Instalar una vez los paquetes de CRAN:
   ```r
   install.packages(c('lmtest','sandwich','cluster','ggplot2'))
   ```
4. Ejecutar desde la consola de RStudio:
   ```r
   source('script/00_ejecutar_todo.R', encoding='UTF-8')
   ```
5. Los resultados quedarán bajo `output/tablas/` y `output/graficos/`.

**Importante:** en el entorno donde se preparó este proyecto no se dispone de `Rscript`; el código se revisó estructuralmente y los números de control fueron comprobados de forma independiente con Python contra los CSV originales, **pero no se ha ejecutado el pipeline íntegro en R**. Deben ejecutarlo en RStudio y revisar posibles errores o diferencias (especialmente el clustering) antes de presentarlo como reproducido.

## Estructura y flujo
```
grupo20_proyecto_final_R/
├── raw/                      # 2 archivos originales inalterados
├── auxiliar/                 # tablas/barrios de apoyo y referencias
├── input/                    # se genera listings_preparado.csv
├── output/
│   ├── tablas/               # auditoría, descriptivos, modelos, controles
│   └── graficos/             # JPG a 300 dpi (ggsave) + PNG auxiliares
├── script/
│   ├── 00_ejecutar_todo.R
│   ├── 01_preparacion.R
│   ├── 02_descriptivos_concentracion.R
│   ├── 03_regresion.R
│   ├── 04_clustering.R
│   ├── 05_graficos.R
│   └── 06_control_calidad.R
├── utils/funciones_comunes.R
└── proyecto.Rproj
```

## Decisiones metodológicas
- **Precio NA:** no se imputa. Solo se excluye de análisis del precio; otros estudios pueden conservar el anuncio.
- **Reseñas/mes NA:** se transforma a 0 si el anuncio tiene 0 reseñas totales, conservando el original.
- **Outliers:** se registran los umbrales de IQR (también sobre log(precio)) y los casos sospechosos. **No se borran automáticamente** precios altos del modelo principal. Se estiman modelos de sensibilidad.
- **Regresión:** log(precio) vs. capacidad, tipo y barrio; barrios con menos de 30 casos se agrupan solo para el modelo, con Palermo y vivienda completa como referencias. Inferencia agrupada por anfitrión, pruebas BP, VIF, RESET aproximado, Cook, modelo cuadrático como sensibilidad. Los porcentajes `100*(exp(beta)-1)` no son efectos causales.
- **Concentración:** CR4, CR8 y HHI por proporción de anuncios por barrio, no índices de poder de mercado empresarial. La oferta geográfica concentrada no demuestra gentrificación.
- **Clustering:** unidad de análisis **anfitrión**. K-means sobre cantidad de anuncios por anfitrión, disponibilidad promedio y reseñas promedio. Se trunca solo para K-means la primera variable al percentil 99; al describir el grupo se distingue explícitamente su media original de la media winsorizada. El algoritmo **nativo de R puede asignar grupos algo distintos** de la implementación Python usada en la entrega anterior: se deben utilizar **las cifras que realmente genere R** antes de cerrar el PowerPoint.
- **Gráficos:** el exploratorio es el mapa de calor (15 barrios, 2 tipos, capacidades 1–6), con gris si n<20. El comunicativo aquí es **una propuesta mejorada**, todavía pendiente de la revisión narrativa final.

## Carpeta / resultados
- `output/tablas/01_*`: faltantes, disponibilidad, reseñas, umbrales y casos a investigar.
- `output/tablas/02_*`: precios, tipos, CR4/CR8/HHI, anuncios por barrio.
- `output/tablas/03_*`: regresión, errores estándar agrupados, VIF, observaciones influyentes y sensibilidad.
- `output/tablas/04_*`: centroides/grupos, selección de k, promedios reales vs. winsorizados y participación en anuncios.
- `output/tablas/05_*`: comparación Puerto Madero–resto de CABA.
- `output/tablas/06_control_calidad.csv`: comprobaciones automáticas.
- `output/graficos/grupo_20_*.jpg`: dos JPG exportados con `ggsave()` a 300 dpi.

## Verificación de procedencia
Se incluyen `auxiliar/hashes_originales_sha256.csv` y `auxiliar/valores_referencia_python.csv` para cotejar integridad de los datos y valores de control. Esta tabla de control **no constituye resultados ejecutados en R**.

