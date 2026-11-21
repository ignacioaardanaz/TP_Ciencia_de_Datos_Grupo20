# 01 - BASE ORIGINAL + VALORES FALTANTES Y OUTLIERS (NO BORRA PRECIOS ALTOS)
source('utils/funciones_comunes.R',encoding='UTF-8')
verificar_raiz(); preparar_carpetas()
corto <- 'raw/listings.csv'
largo <- 'raw/listings.csv(1).gz'
if (!file.exists(corto) || !file.exists(largo)) stop('Faltan los archivos originales en raw/.')
a <- read.csv(corto,colClasses=c(id='character',host_id='character'),stringsAsFactors=FALSE,check.names=FALSE)
b <- read.csv(gzfile(largo),colClasses=c(id='character',host_id='character'),stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(a)==29753L,nrow(b)==29753L,!anyDuplicated(a$id),!anyDuplicated(b$id))
pos <- match(a$id,b$id)
stopifnot(!anyNA(pos))
a$accommodates <- as.integer(b$accommodates[pos])
a$last_scraped <- b$last_scraped[pos]

# Todas las observaciones siguen en la base preparada.
vars <- c('id','host_id','price','availability_365','number_of_reviews',
          'reviews_per_month','minimum_nights','accommodates','neighbourhood','room_type')
faltantes <- data.frame(variable=vars, n_faltantes=vapply(a[vars],function(x) sum(is.na(x)),numeric(1)))
faltantes$porcentaje <- round(100*faltantes$n_faltantes/nrow(a),4)
write.csv(faltantes,'output/tablas/01_faltantes.csv',row.names=FALSE)

na_precio <- is.na(a$price)
cruce_precio <- data.frame(disponibilidad=c('Precio NA; 0 dias','Precio NA; >0 dias',
                                'Precio observado; 0 dias','Precio observado; >0 dias'),
 cantidad=c(sum(na_precio & a$availability_365==0),sum(na_precio & a$availability_365>0),
            sum(!na_precio & a$availability_365==0),sum(!na_precio & a$availability_365>0)))
write.csv(cruce_precio,'output/tablas/01_precio_disponibilidad.csv',row.names=FALSE)

# Solo los nulos de reseñas/mes que tienen cero reseñas se interpretan como cero.
a$reviews_per_month_tratada <- a$reviews_per_month
cambiar <- is.na(a$reviews_per_month) & a$number_of_reviews==0
a$reviews_per_month_tratada[cambiar] <- 0
res_na <- data.frame(indicador=c('Nulos reviews_per_month','Nulos y cero reviews',
                                'Nulos con mas de cero reviews'),
                  cantidad=c(sum(is.na(a$reviews_per_month)),sum(cambiar),
                             sum(is.na(a$reviews_per_month)&a$number_of_reviews>0)))
write.csv(res_na,'output/tablas/01_resenas_faltantes.csv',row.names=FALSE)

# Criterios IQR son DIAGNOSTICOS y analisis de sensibilidad, NO exclusiones.
p <- a$price[!is.na(a$price) & a$price>0]
stopifnot(length(p)>0)
q <- quantile(p,c(.25,.75)); iqr <- diff(q)
logp <- log(p); qlog <- quantile(logp,c(.25,.75)); iqrl <- diff(qlog)
limite_original <- as.numeric(q[2]+1.5*iqr)
log_inferior <- as.numeric(exp(qlog[1]-1.5*iqrl))
log_superior <- as.numeric(exp(qlog[2]+1.5*iqrl))
umbral_revisar <- 100*median(p)
a$flag_IQR_precio_alto <- !is.na(a$price)&a$price>limite_original
a$flag_IQR_log_alto <- !is.na(a$price)&a$price>log_superior
a$flag_IQR_log_bajo <- !is.na(a$price)&a$price<log_inferior
a$flag_revision_extrema <- !is.na(a$price)&a$price>umbral_revisar
umbrales <- data.frame(criterio=c('n anuncios','n precios disponibles','mediana precio',
  'IQR superior precio','IQR inferior log convertido a ARS','IQR superior log convertido a ARS',
  '100 x mediana','n sobre IQR precio','n fuera del IQR log','n sobre 100 x mediana'),
  valor=c(nrow(a),length(p),median(p),limite_original,log_inferior,log_superior,
          umbral_revisar,sum(p>limite_original),sum(p<log_inferior|p>log_superior),sum(p>umbral_revisar)))
write.csv(umbrales,'output/tablas/01_umbrales_y_outliers.csv',row.names=FALSE)
sospechosos <- a[a$flag_revision_extrema,c('id','host_id','name','neighbourhood','room_type','accommodates','price','availability_365')]
sospechosos <- sospechosos[order(-sospechosos$price),]
write.csv(sospechosos,'output/tablas/01_precios_revision_manual.csv',row.names=FALSE)

write.csv(a,'input/listings_preparado.csv',row.names=FALSE,na='')
cat('Preparacion:',nrow(a),'anuncios,',sum(na_precio),'precios NA,',sum(cambiar),'NA resenas -> 0.\n')
cat('Fecha de referencia del grupo: 23/09/2026. last_scraped del archivo:',
     paste(sort(unique(a$last_scraped)),collapse=', '),'(no equivale a un cambio de base).\n')
