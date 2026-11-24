
# Airbnb en CABA — Grupo 20

**Ciencia de Datos | FCE-UBA | Segundo cuatrimestre de 2026**

## 1. Objetivo

Analizar el mercado de alojamientos publicados en Airbnb en la Ciudad Autónoma de Buenos Aires (CABA), a partir de tres ejes principales:

- **Precios:** estudiar la relación entre el precio publicado por noche, la capacidad, el tipo de alojamiento y el barrio.
- **Distribución geográfica:** analizar la concentración de anuncios entre los distintos barrios de CABA.
- **Anfitriones:** identificar perfiles de anfitriones mediante técnicas de agrupamiento.

El trabajo combina análisis descriptivo, visualizaciones, regresión y clustering.

Los resultados permiten identificar **asociaciones, no relaciones causales**. Los precios analizados son valores publicados en Airbnb, no transacciones ni ingresos efectivamente realizados.

## 2. Fuente de datos y período de referencia

Se utilizan exclusivamente los archivos originales proporcionados al grupo, sin nuevas descargas ni sustitución de la base de datos.

**Archivos principales:**

- `raw/listings.csv`: 29.753 anuncios y 19 columnas.
- `raw/listings.csv(1).gz`: 29.753 anuncios y 90 columnas.

La fuente es **Inside Airbnb**, para alojamientos publicados en la Ciudad Autónoma de Buenos Aires.

Se eligió esta base porque permite estudiar conjuntamente los precios publicados, las características de los alojamientos, la ubicación geográfica y los anfitriones.

Entre las variables utilizadas se encuentran:

- `price`: precio publicado.
- `accommodates`: capacidad del alojamiento.
- `room_type`: tipo de alojamiento.
- `neighbourhood_cleansed`: barrio.
- `host_id`: identificador del anfitrión.
- `last_scraped`: fecha de captura del registro.

### Aclaración sobre las fechas

Utilizamos históricamente el **23/09/2026** como fecha de referencia.

Sin embargo, en el archivo detallado, la variable `last_scraped` registra capturas del **25, 26 y 27 de septiembre de 2026**.

Por lo tanto, los resultados corresponden a los archivos originales recibidos, pero no se presentan como un corte verificado al 23/09/2026.

No se descargaron nuevas versiones de la base.

En `auxiliar/` se conservan los archivos complementarios de barrios y las referencias de control.

Los archivos extensos de calendarios y reseñas no son necesarios para reproducir los análisis incluidos en este repositorio y no fueron incorporados.

## 3. Organización del repositorio

El repositorio se organiza siguiendo la estructura solicitada para el trabajo práctico.

```text
TP_Ciencia_de_Datos_Grupo20/
├── raw/
│   ├── listings.csv
│   └── listings.csv(1).gz
│
├── auxiliar/
│   └── Archivos complementarios y controles
│
├── input/
│   └── Datos preparados para el análisis
│
├── output/
│   ├── tablas/
│   └── graficos/
│
├── script/
│   ├── 00_ejecutar_todo.R
│   ├── 01_preparacion.R
│   ├── 02_descriptivos_concentracion.R
│   ├── 03_regresion.R
│   ├── 04_clustering.R
│   ├── 05_graficos.R
│   ├── 06_control_calidad.R
│   └── 07_grafico_comunicativo_precio_vs_oferta.R
│
├── utils/
│   ├── funciones_comunes.R       # Cargador de funciones
│   ├── verificar_raiz.R
│   ├── preparar_carpetas.R
│   ├── verificar_paquetes.R
│   ├── leer_preparado.R
│   ├── formato_ars.R
│   ├── formato_entero.R
│   ├── pct.R
│   ├── centros_plus_plus.R
│   ├── ajustar_kmeans.R
│   └── fmt.R
│
├── proyecto.Rproj
└── README.md
```

### Función de cada carpeta

- **`raw/`:** almacena los datos originales, sin modificaciones.
- **`auxiliar/`:** contiene archivos complementarios y referencias de control.
- **`input/`:** contiene los datos preparados para los análisis.
- **`output/tablas/`:** almacena tablas, indicadores y resultados calculados.
- **`output/graficos/`:** contiene las visualizaciones generadas.
- **`script/`:** reúne los scripts de R utilizados en el proyecto.
- **`utils/`:** contiene una función auxiliar por archivo. `funciones_comunes.R` es solamente un cargador que invoca los diez scripts individuales; no contiene definiciones de funciones. Los análisis conservan la misma lógica y utilizan ese cargador.


Los archivos originales almacenados en `raw/` no se modifican.

## 4. Cómo reproducir el análisis en RStudio

### Requisitos

Para ejecutar el proyecto se necesita:

- R.
- RStudio.
- Los paquetes `lmtest`, `sandwich`, `cluster` y `ggplot2`.

### Paso 1. Descargar el repositorio

Clonar o descargar el repositorio desde GitHub, conservando su estructura de carpetas.

### Paso 2. Abrir el proyecto

Abrir el archivo `proyecto.Rproj` en RStudio.

El directorio de trabajo debe ser la carpeta principal del repositorio, que contiene `raw/`, `script/` y `output/`.

### Paso 3. Instalar los paquetes necesarios

Ejecutar una sola vez:

```r
install.packages(c(
  "lmtest",
  "sandwich",
  "cluster",
  "ggplot2"
))
```

### Paso 4. Ejecutar el análisis general

Desde la consola de RStudio:

```r
source(
  "script/00_ejecutar_todo.R",
  encoding = "UTF-8"
)
```

### Paso 5. Ejecutar el gráfico comunicativo actualizado

Para generar específicamente la comparación entre precios y cantidad de anuncios por barrio:

```r
source(
  "script/07_grafico_comunicativo_precio_vs_oferta.R",
  encoding = "UTF-8"
)
```

Este script calcula los indicadores **desde `input/listings_preparado.csv`**, generado a partir de los archivos originales, y escribe:

- `output/tablas/07_precio_oferta_por_barrio.csv`
- `output/graficos/grupo_20_comunicativo.png`

El script `00_ejecutar_todo.R` incluye el paso 07 al final del flujo. El script 05 genera el exploratorio y conserva la tabla de comparación requerida para el control de calidad; ya no sobrescribe el comunicativo.

### Paso 6. Verificar los resultados

Los resultados se almacenan en:

- `output/tablas/`
- `output/graficos/`

Para controlar la ejecución se recomienda:

1. Verificar que no aparezcan errores durante la ejecución de los scripts.
2. Revisar `output/tablas/06_control_calidad.csv`.
3. Contrastar los indicadores generados con las tablas de referencia.
4. Verificar los resultados del clustering.
5. Confirmar que los gráficos generados correspondan a los resultados presentados.

El gráfico comunicativo fue ejecutado y comprobado en RStudio. La ejecución correcta de ese script específico no sustituye la verificación del proyecto completo. 

## 5. Decisiones metodológicas

### 5.1. Tratamiento de precios faltantes

Los precios faltantes no se imputan.

Los anuncios sin precio se excluyen únicamente de aquellos análisis que requieren esta variable.

### 5.2. Tratamiento de reseñas faltantes

Cuando un anuncio registra cero reseñas totales y presenta un valor faltante en las reseñas mensuales, se interpreta ese faltante como cero para las variables derivadas correspondientes.

El dato original se conserva.

### 5.3. Tratamiento de valores extremos

Se identifican y documentan valores extremos mediante el criterio del rango intercuartílico (IQR), tanto sobre el precio como sobre su logaritmo.

Los precios altos **no se eliminan automáticamente** del modelo principal.

También se realizan análisis de sensibilidad para evaluar la influencia de las observaciones extremas.

### 5.4. Regresión

Se utiliza el logaritmo del precio publicado como variable dependiente.

Las principales variables explicativas son:

- Capacidad del alojamiento.
- Tipo de alojamiento.
- Barrio.

Se utilizan **Palermo** y **vivienda completa** como categorías de referencia.

Los barrios con pocas observaciones se agrupan para la estimación del modelo.

Se calculan errores estándar agrupados por anfitrión y se realizan diagnósticos adicionales:

- Heterocedasticidad (Breusch-Pagan).
- Multicolinealidad (VIF).
- Especificación funcional (RESET aproximado).
- Observaciones influyentes (distancia de Cook).
- Modelos alternativos de sensibilidad.


### 5.5. Concentración geográfica

Se calculan indicadores de concentración de anuncios entre barrios:

- **CR4:** participación acumulada de los cuatro barrios con mayor cantidad de anuncios.
- **CR8:** participación acumulada de los ocho barrios con mayor cantidad de anuncios.
- **HHI:** índice calculado a partir de las participaciones de anuncios por barrio.

Estos indicadores describen la concentración territorial de la oferta publicada.

No deben interpretarse directamente como medidas de poder de mercado empresarial ni como pruebas de procesos de gentrificación.

### 5.6. Clustering de anfitriones

La unidad de análisis es el **anfitrión**, no el anuncio individual.

Se utiliza el algoritmo **K-means**, considerando variables relacionadas con:

- Cantidad de anuncios por anfitrión.
- Disponibilidad promedio.
- Reseñas promedio.

Para reducir la influencia de valores extremos sobre el algoritmo, la cantidad de anuncios se limita al percentil 99 durante el agrupamiento.

Al describir los grupos, se diferencia entre:

- Los valores originales.
- Los valores utilizados por el algoritmo después del tratamiento de extremos.

Los resultados definitivos del clustering deben corresponder a la ejecución realizada en R.

## 6. Visualizaciones principales

### 6.1. Gráfico exploratorio

**Archivo:**

`output/graficos/grupo_20_exploratorio.jpeg`

Se presenta un mapa de calor que compara los precios medianos publicados según:

- Barrio.
- Tipo de alojamiento.
- Capacidad.

El gráfico permite explorar diferencias entre múltiples combinaciones de características.

Se consideran 15 barrios, dos tipos de alojamiento y capacidades de uno a seis huéspedes.

Las combinaciones con menos de 20 anuncios se distinguen visualmente para advertir sobre su menor respaldo muestral.

**Objetivo:** identificar patrones, diferencias y posibles relaciones para profundizar mediante otros análisis.

### 6.2. Gráfico comunicativo

**Archivo publicado:**

`output/graficos/grupo_20_comunicativo.png`

**Script utilizado:**

`script/07_grafico_comunicativo_precio_vs_oferta.R`

Se presenta un gráfico de dispersión que relaciona dos variables:

- **Eje horizontal:** precio mediano publicado por noche.
- **Eje vertical:** cantidad de anuncios.

Cada punto representa un barrio de CABA.

Para asegurar una comparación más homogénea, se consideran únicamente:

- Viviendas completas.
- Alojamientos con capacidad para exactamente dos huéspedes.
- Publicaciones con precio válido.
- Barrios con al menos 30 anuncios que cumplen los criterios anteriores.

Se destacan seis barrios representativos:

1. Palermo.
2. Puerto Madero.
3. Recoleta.
4. Belgrano.
5. Villa Crespo.
6. San Telmo.

**Mensaje principal:**

Puerto Madero presenta un precio mediano publicado considerablemente mayor, mientras que Palermo concentra una cantidad mucho más alta de anuncios comparables.

Los otros cuatro barrios destacados permiten contextualizar esa diferencia dentro del mercado de CABA.

El gráfico busca transmitir este hallazgo de forma directa y comprensible, incluso para personas que no conocen previamente el trabajo.

No se utiliza el tamaño de los puntos para representar reservas ni se infiere ocupación a partir de las reseñas.

La tabla con los datos utilizados se encuentra en:

`output/tablas/07_precio_oferta_por_barrio.csv`

## 7. Tablas y controles

Las tablas del proyecto se organizan según el análisis correspondiente.

| Archivos | Contenido |
|---|---|
| `01_*` | Calidad de datos, faltantes, disponibilidad, reseñas y valores extremos. |
| `02_*` | Estadísticos descriptivos, precios y concentración geográfica. |
| `03_*` | Modelos de regresión, diagnósticos y análisis de sensibilidad. |
| `04_*` | Clustering, perfiles de anfitriones y concentración de anuncios. |
| `05_*` | Comparación de precios entre Puerto Madero y el resto de CABA. |
| `06_control_calidad.csv` | Comprobaciones automáticas de calidad y consistencia. |
| `07_precio_oferta_por_barrio.csv` | Precio mediano y cantidad de anuncios por barrio para el gráfico comunicativo. |

Los archivos se almacenan en `output/tablas/`.

### Controles de procedencia

En `auxiliar/` se incluyen:

- `hashes_originales_sha256.csv`
- `valores_referencia_python.csv`

Permiten cotejar la integridad de los archivos originales y comparar resultados con valores de referencia.

Las referencias calculadas en Python no sustituyen la ejecución del análisis en R.

## 8. Alcance y limitaciones

Los resultados permiten describir diferencias entre anuncios, barrios y perfiles de anfitriones.

Sin embargo, deben considerarse algunas limitaciones:

- El análisis es descriptivo y asociativo, no causal.
- Los precios son valores publicados, no precios efectivamente pagados.
- La cantidad de anuncios no equivale a la cantidad de reservas.
- Las reseñas no permiten identificar directamente la ocupación real.
- La concentración territorial de anuncios no demuestra por sí sola poder de mercado.
- Las comparaciones del gráfico comunicativo controlan el tipo de alojamiento y la capacidad, pero no todas las características particulares de las propiedades.
- Los resultados corresponden exclusivamente a los archivos originales utilizados.

Las conclusiones deben interpretarse dentro de estos límites.


