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

# Descriptivo mas rico: rangos P25-P75 por barrio, el mensaje es la
# comparacion entre Puerto Madero y todo el resto, no con un barrio elegido.
q1 <- aggregate(price~neighbourhood,data=seg,FUN=function(x) unname(quantile(x,.25)))
q3 <- aggregate(price~neighbourhood,data=seg,FUN=function(x) unname(quantile(x,.75)))
md <- aggregate(price~neighbourhood,data=seg,FUN=median)
ng <- aggregate(price~neighbourhood,data=seg,FUN=length)
names(q1)[2]<-'q25';names(q3)[2]<-'q75';names(md)[2]<-'mediana';names(ng)[2]<-'n'
db <- Reduce(function(x,y)merge(x,y,by='neighbourhood'),list(q1,q3,md,ng))
show_b <- names(sort(table(seg$neighbourhood),decreasing=TRUE))[1:15]
db <- db[db$neighbourhood %in% show_b,]
db$destacado <- ifelse(db$neighbourhood=='Puerto Madero','Puerto Madero','Otros barrios')
db$neighbourhood <- factor(db$neighbourhood,levels=names(sort(setNames(db$mediana,db$neighbourhood))))

p_comunicativo <- ggplot2::ggplot(db,ggplot2::aes(y=neighbourhood,x=mediana))+
 ggplot2::geom_vline(xintercept=mediana_resto,color='#2A5360',linetype='dashed',linewidth=.9)+
 ggplot2::geom_segment(ggplot2::aes(x=q25,xend=q75,yend=neighbourhood,color=destacado),
                       linewidth=2.2,alpha=.85)+
 ggplot2::geom_point(ggplot2::aes(color=destacado),size=3.1)+
 ggplot2::scale_color_manual(values=c('Puerto Madero'='#D4764C','Otros barrios'='#ADB9BC'),guide='none')+
 ggplot2::scale_x_continuous(labels=function(x) paste0('$',round(x/1000),' mil'),
       limits=c(0,300000),breaks=seq(0,300000,50000))+
 ggplot2::labs(title=paste0('Puerto Madero supera en ',round(premium),
           '% al resto de CABA en el precio mediano'),
  subtitle='Viviendas completas para 2 huespedes. Medianas anunciadas por noche (ARS).',
  x='Precio anunciado (ARS)',y=NULL,
  caption=paste0('Fuente: Inside Airbnb (septiembre 2026). Puerto Madero n=',nrow(pm),
      '; resto n=',nrow(resto),'. Barras: del cuartil 25 al 75; puntos: mediana.'))+
 ggplot2::annotate('label',x=180000,y='Puerto Madero',
   label=paste0('+',round(premium),'% frente al resto de CABA'),
   color='#C25B36',fill='#FFF1E8',fontface='bold',size=3.7,vjust=-1.1)+
 ggplot2::theme_minimal(base_size=12)+
 ggplot2::theme(plot.background=ggplot2::element_rect(fill='#FAF8F3',color=NA),
       panel.grid.major.y=ggplot2::element_blank(),panel.grid.minor=ggplot2::element_blank(),
       plot.title=ggplot2::element_text(face='bold',size=16,color='#20353B'),
       axis.text.y=ggplot2::element_text(color='#20353B'),
       plot.caption=ggplot2::element_text(hjust=0,color='#5B686C',size=8))
ggplot2::ggsave('output/graficos/grupo_20_comunicativo.jpg',p_comunicativo,
                 width=25,height=18,units='cm',dpi=300,bg='#FAF8F3')
cat('Graficos generados. Mediana Puerto Madero:',mediana_pm,
    'resto:',mediana_resto,'diferencia %:',premium,'\n')
