# 05 - GRAFICOS DE LA INSTANCIA 3, A PARTIR DEL MISMO INPUT
# Candidato comunicativo con mensaje explicito (+87%); revisarlo antes de la defensa.
source('utils/funciones_comunes.R',encoding='UTF-8')
verificar_raiz(); preparar_carpetas(); verificar_paquetes(c('ggplot2'))
a <- leer_preparado()
v <- a[!is.na(a$price)&a$price>0&!is.na(a$accommodates),]
v$tipo <- ifelse(v$room_type=='Entire home/apt','Vivienda completa',
                 ifelse(v$room_type=='Private room','Habitacion privada','Otros'))

# EXPLORATORIO: mapa barrio x capacidad x tipo; n<20 se marca en gris.
barrios <- names(sort(table(v$neighbourhood),decreasing=TRUE))[1:15]
s <- v[v$neighbourhood %in% barrios & v$accommodates>=1 & v$accommodates<=6 &
         v$tipo %in% c('Vivienda completa','Habitacion privada'),]
med <- aggregate(price ~ neighbourhood+tipo+accommodates,data=s, FUN=median)
ns <- aggregate(price ~ neighbourhood+tipo+accommodates,data=s,FUN=length)
names(ns)[4] <- 'n'
tabla <- merge(med,ns,by=c('neighbourhood','tipo','accommodates'))
# Generar grilla completa incluso para combinaciones sin anuncios.
combos <- expand.grid(neighbourhood=barrios,
                     tipo=c('Vivienda completa','Habitacion privada'),
                     accommodates=1:6,stringsAsFactors=FALSE)
tabla <- merge(combos,tabla,by=c('neighbourhood','tipo','accommodates'),all.x=TRUE,sort=FALSE)
tabla$n[is.na(tabla$n)] <- 0
tabla$mediana_grafica <- ifelse(tabla$n>=20,tabla$price,NA_real_)
tabla$etiqueta <- ifelse(tabla$n>=20,as.character(round(tabla$price/1000)), '')
tabla$neighbourhood <- factor(tabla$neighbourhood,levels=rev(barrios))
tabla$tipo <- factor(tabla$tipo,levels=c('Vivienda completa','Habitacion privada'))

p_exploratorio <- ggplot2::ggplot(tabla,ggplot2::aes(x=factor(accommodates),y=neighbourhood,fill=mediana_grafica))+
  ggplot2::geom_tile(color='#FFFFFF',linewidth=.5)+
  ggplot2::geom_text(ggplot2::aes(label=etiqueta),size=2.7,color='#152C37')+
  ggplot2::facet_grid(.~tipo)+
  ggplot2::scale_fill_gradientn(colours=c('#6AA9D4','#CCE7ED','#F6E4AC','#F4A361','#C93D4D'),
       na.value='#D7D8D9',name='Mediana (ARS)',labels=function(x) round(x/1000))+
  ggplot2::labs(title='Precio mediano por noche segun barrio, tipo de alojamiento y capacidad',
    subtitle='Precio mediano por noche (miles de ARS). Gris: menos de 20 anuncios.',
    x='Capacidad de huespedes',y='Barrio',
    caption='Fuente: Inside Airbnb (septiembre de 2026).')+
  ggplot2::theme_minimal(base_size=11)+
  ggplot2::theme(plot.background=ggplot2::element_rect(fill='#FAF8F3',color=NA),
    panel.grid=ggplot2::element_blank(),strip.text=ggplot2::element_text(face='bold',size=12),
    axis.text.y=ggplot2::element_text(size=9),
    plot.title=ggplot2::element_text(face='bold',size=15,color='#20353B'),
    plot.subtitle=ggplot2::element_text(size=10),plot.caption=ggplot2::element_text(size=9))
ggplot2::ggsave('output/graficos/grupo_20_exploratorio.jpg',p_exploratorio,
                width=25,height=18,units='cm',dpi=300,bg='#FAF8F3')

# COMUNICATIVO: 15 barrios como contexto, pero UN SOLO mensaje y comparacion
# con todas las viviendas completas para dos huespedes del resto de CABA.
seg <- v[v$tipo=='Vivienda completa' & v$accommodates==2,]
pm <- seg[seg$neighbourhood=='Puerto Madero',]
resto <- seg[seg$neighbourhood!='Puerto Madero',]
stopifnot(nrow(pm)>0,nrow(resto)>0)
mediana_pm <- median(pm$price)
mediana_resto <- median(resto$price)
premium <- 100*(mediana_pm/mediana_resto-1)
resumen_segmento <- data.frame(grupo=c('Puerto Madero','Resto de CABA'),
 n=c(nrow(pm),nrow(resto)),mediana=c(mediana_pm,mediana_resto))
write.csv(resumen_segmento,'output/tablas/05_comparacion_puerto_madero_resto.csv',row.names=FALSE)

# Los graficos comunicativos anteriores se retiraron de este script.
# El grafico comunicativo definitivo se calcula desde los datos reales en
# script/07_grafico_comunicativo_precio_vs_oferta.R.
# Aqui mantenemos solo el grafico exploratorio y la tabla 05 requerida
# por script/06_control_calidad.R.
cat('Exploratorio y tabla 05 generados. Mediana Puerto Madero:',
    mediana_pm, 'resto:', mediana_resto, 'diferencia %:', premium, '\n')
