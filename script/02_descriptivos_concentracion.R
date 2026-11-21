# 02 - DESCRIPTIVOS + INDICES ESPACIALES CR4, CR8, HHI
source('utils/funciones_comunes.R',encoding='UTF-8'); verificar_raiz(); preparar_carpetas()
a <- leer_preparado()
precios <- a$price[!is.na(a$price)&a$price>0]
medidas <- data.frame(indicador=c('N anuncios','N anuncios con precio','Media precio (ARS)',
 'Mediana precio (ARS)','Q1 precio','Q3 precio','Minimo','Maximo'),
 valor=c(nrow(a),length(precios),mean(precios),median(precios),quantile(precios,.25),
         quantile(precios,.75),min(precios),max(precios)))
write.csv(medidas,'output/tablas/02_estadisticas_precio.csv',row.names=FALSE)

por_tipo <- as.data.frame(table(a$room_type),stringsAsFactors=FALSE)
names(por_tipo)<-c('tipo','n'); por_tipo$porcentaje <- 100*por_tipo$n/nrow(a)
write.csv(por_tipo,'output/tablas/02_tipo_alojamiento.csv',row.names=FALSE)

n_barrios <- sort(table(a$neighbourhood),decreasing=TRUE)
barrios <- data.frame(barrio=names(n_barrios),anuncios=as.integer(n_barrios),
                     porcentaje=100*as.numeric(n_barrios)/nrow(a))
write.csv(barrios,'output/tablas/02_concentracion_por_barrio.csv',row.names=FALSE)
fr <- as.numeric(n_barrios)/nrow(a)
indices <- data.frame(indice=c('CR4 (%)','CR8 (%)','HHI (0-10000)','N barrios representados'),
                      valor=c(100*sum(head(fr,4)),100*sum(head(fr,8)),10000*sum(fr^2),length(fr)))
write.csv(indices,'output/tablas/02_indices_concentracion.csv',row.names=FALSE)
stopifnot(abs(sum(fr)-1)<1e-10)
cat('CR4:',round(indices$valor[1],2),'% / CR8:',round(indices$valor[2],2),
    '% / HHI:',round(indices$valor[3],2),'\n')
