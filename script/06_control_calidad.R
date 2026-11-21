# 06 - PRUEBAS DE INTEGRIDAD DE LOS RESULTADOS
source('utils/funciones_comunes.R',encoding='UTF-8')
verificar_raiz(); preparar_carpetas()
a <- leer_preparado()
con <- read.csv('output/tablas/02_indices_concentracion.csv')
reg <- read.csv('output/tablas/03_regresion_resumen.csv')
clus <- read.csv('output/tablas/04_clusters_resumen.csv')
com <- read.csv('output/tablas/05_comparacion_puerto_madero_resto.csv')
checks <- c(
 '29753 publicaciones' = nrow(a)==29753,
 '14623 anfitriones' = length(unique(a$host_id))==14623,
 '2119 precios faltantes' = sum(is.na(a$price))==2119,
 '3479 resenas por mes faltantes antes de recodificar' = sum(is.na(a$reviews_per_month))==3479,
 'precios conservados en base preparada' = nrow(a[a$price>0 & !is.na(a$price),])==27634,
 'CR4 coherente' = abs(con$valor[con$indice=='CR4 (%)'] - 59.41921823) < 0.02,
 'HHI coherente' = abs(con$valor[con$indice=='HHI (0-10000)'] - 1458.7664)<0.1,
 'regresion usa 27634 anuncios' = reg$n==27634,
 'clusters suman 14623 hosts' = sum(clus$hosts)==14623,
 'clusters suman 29753 anuncios' = sum(clus$listings)==29753,
 'promedio winsorizado <= percentil 99' = all(clus$avg_listings_winsor<=18.0000001),
 'Puerto Madero mediana 180401' = abs(com$mediana[com$grupo=='Puerto Madero']-180401)<1,
 'resto de CABA mediana 96316' = abs(com$mediana[com$grupo=='Resto de CABA']-96316)<1
)
resultado <- data.frame(prueba=names(checks),ok=as.logical(checks))
write.csv(resultado,'output/tablas/06_control_calidad.csv',row.names=FALSE)
print(resultado,row.names=FALSE)
if (!all(checks)) stop('Hay comprobaciones fallidas. Revisar output/tablas/06_control_calidad.csv')
cat('CONTROLES PASADOS:',sum(checks),'de',length(checks),'\n')
