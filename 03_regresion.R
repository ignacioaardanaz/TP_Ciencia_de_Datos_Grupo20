# 03 - REGRESION LOG(PRECIO) + ERRORES ROBUSTOS + SENSIBILIDAD
source('utils/funciones_comunes.R',encoding='UTF-8')
verificar_raiz(); preparar_carpetas(); verificar_paquetes(c('sandwich','lmtest'))
short <- leer_preparado()
# 2. Seleccion sin recorte automatico de precios extremos.
vars <- c('id','host_id','price','accommodates','room_type','neighbourhood')
validos <- complete.cases(short[, vars]) & short$price > 0
validos[is.na(validos)] <- FALSE
datos <- short[validos, vars, drop=FALSE]
datos$log_precio <- log(datos$price)

# 3. Pooling de barrios con muy pocos anuncios con precio: < 30 casos.
#    Es una recodificacion SOLO para el modelo, no se alteran los datos originales.
frecuencias <- table(datos$neighbourhood)
barrios_pocos <- names(frecuencias)[frecuencias < 30L]
datos$barrio_modelo <- ifelse(datos$neighbourhood %in% barrios_pocos,
                              'Otros (<30 anuncios)', datos$neighbourhood)
datos$room_type <- relevel(factor(datos$room_type), ref='Entire home/apt')
datos$barrio_modelo <- relevel(factor(datos$barrio_modelo), ref='Palermo')
cat('Muestra final:', nrow(datos), 'anuncios; anfitriones:', length(unique(datos$host_id)), '\n')
cat('Barrios agrupados:', length(barrios_pocos), 'con', sum(datos$neighbourhood %in% barrios_pocos), 'anuncios\n')

# 4. Modelo principal. Precio en logaritmos, capacidad, tipo y barrio.
form <- log_precio ~ accommodates + room_type + barrio_modelo
mod <- lm(form, data=datos)
cat('\nREGRESION PRINCIPAL (sin recortar los precios altos):\n')
print(summary(mod))

# 5. Inferencia robusta (heterocedasticidad y correlacion dentro de host_id).
g <- length(unique(datos$host_id))
vc <- sandwich::vcovCL(mod, cluster=datos$host_id, type='HC1')
rob <- lmtest::coeftest(mod, vcov.=vc, df=g-1)
cat('\nCOEFICIENTES CON ERRORES ESTANDAR AGRUPADOS POR ANFITRION:\n')
print(rob)

# Estimaciones porcentuales: ratio de exp(beta) para el precio en escala log.
# No equivalen automaticamente a efectos causales ni a cambios de la media aritmetica.
b <- coef(mod); se <- sqrt(diag(vc)); tcrit <- qt(.975, df=g-1)
res <- data.frame(variable=names(b), beta=unname(b), error_estandar_agrupado=unname(se),
                  p_valor=unname(2*pt(abs(b/se), df=g-1, lower.tail=FALSE)),
                  diferencia_pct=unname(100*expm1(b)),
                  ci95_inferior_pct=unname(100*expm1(b-tcrit*se)),
                  ci95_superior_pct=unname(100*expm1(b+tcrit*se)),
                  row.names=NULL)
write.csv(res, file.path('output','tablas','03_regresion_coeficientes.csv'), row.names=FALSE)

# Prueba F robusta conjunta: todas las pendientes del modelo = 0.
vec <- b[-1]; mat <- vc[-1,-1,drop=FALSE]; q <- length(vec)
F_robusta <- as.numeric(crossprod(vec, solve(mat, vec)) / q)
p_robusta <- pf(F_robusta, df1=q, df2=g-1, lower.tail=FALSE)
cat(sprintf('F conjunta robusta: F(%d,%d)=%.4f, p=%g\n', q, g-1, F_robusta, p_robusta))

# 6. Diagnosticos solicitados por el profesor.
# 6A. Heterocedasticidad: Breusch-Pagan.
cat('\nBREUSCH-PAGAN:\n'); print(lmtest::bptest(mod))

# 6B. Multicolinealidad: VIF individual de las dummies del modelo.
#     Para interpretar factores completos se recomienda GVIF; aqui mostramos VIF por columna.
X <- model.matrix(mod)[,-1,drop=FALSE]
V <- diag(solve(cor(X)))
vif_tab <- data.frame(variable=names(V), VIF=as.numeric(V))
vif_tab <- vif_tab[order(-vif_tab$VIF), ]
write.csv(vif_tab, file.path('output','tablas','03_regresion_vif.csv'), row.names=FALSE)
cat('\nVIF maximo por columna:', max(V), '\nVIF capacidad:', unname(V['accommodates']), '\n')

# 6C. Forma funcional: prueba RESET aproximada agregando el cuadrado de los ajustados.
datos$ajustado_cuadrado <- fitted(mod)^2
mod_reset <- lm(log_precio ~ accommodates + room_type + barrio_modelo + ajustado_cuadrado, data=datos)
reset_coef <- lmtest::coeftest(mod_reset, vcov.=sandwich::vcovHC(mod_reset, type='HC3'))
cat('\nRESET (termino cuadratico de predichos; HC3):\n')
print(reset_coef['ajustado_cuadrado', ,drop=FALSE])

# 6D. Observaciones influyentes. No borrar automaticamente con un umbral de Cook.
cook <- cooks.distance(mod); hat <- hatvalues(mod)
datos$cooks_d <- cook; datos$leverage <- hat
write.csv(datos[order(-cook), c('id','price','room_type','neighbourhood','accommodates','cooks_d','leverage')][1:20, ],
          file.path('output','tablas','03_regresion_influencia_top20.csv'), row.names=FALSE)
cat('\nCook > 4/n:', sum(cook > 4/nrow(datos)), 'de', nrow(datos), '\n')

# 7. Comparaciones de sensibilidad: sin recorte, IQR en log(precio), antiguo IQR en pesos.
qlog <- quantile(datos$log_precio, c(.25, .75)); spread <- diff(qlog)
lim_inf_log <- exp(qlog[1] - 1.5*spread)
lim_sup_log <- exp(qlog[2] + 1.5*spread)
sub_log <- datos[datos$price >= lim_inf_log & datos$price <= lim_sup_log, ]
mod_log <- lm(form, data=sub_log)
qraw <- quantile(datos$price,c(.25,.75));lim_sup_raw <- qraw[2]+1.5*diff(qraw)
sub_raw <- datos[datos$price<=lim_sup_raw, ]
mod_raw <- lm(form, data=sub_raw)

# 8. Sensibilidad: revisar forma funcional alternativa con capacidad cuadratica.
mod_cuad <- lm(update(form, . ~ . + I(accommodates^2)), data=datos)
vc_cuad <- sandwich::vcovCL(mod_cuad, cluster=datos$host_id, type='HC1')
cat('\nCAPACIDAD CUADRATICA (sensibilidad):\n')
print(lmtest::coeftest(mod_cuad, vcov.=vc_cuad, df=g-1)['I(accommodates^2)',,drop=FALSE])

pct <- function(m, term) if (term %in% names(coef(m))) 100*expm1(coef(m)[[term]]) else NA_real_
puerto <- 'barrio_modeloPuerto Madero'
comparacion <- data.frame(
  modelo=c('Sin recorte','IQR de log(precio)','IQR del precio','Capacidad cuadratica'),
  n=c(nobs(mod),nobs(mod_log),nobs(mod_raw),nobs(mod_cuad)),
  R2=c(summary(mod)$r.squared, summary(mod_log)$r.squared,
       summary(mod_raw)$r.squared, summary(mod_cuad)$r.squared),
  capacidad_pct=c(pct(mod,'accommodates'),pct(mod_log,'accommodates'),pct(mod_raw,'accommodates'),NA_real_),
  puerto_madero_vs_palermo_pct=c(pct(mod,puerto),pct(mod_log,puerto),
                                 pct(mod_raw,puerto),pct(mod_cuad,puerto)))
write.csv(comparacion, file.path('output','tablas','03_regresion_sensibilidad.csv'), row.names=FALSE)
print(comparacion)
resumen_modelo <- data.frame(n=nobs(mod), n_anfitriones=g, R2=summary(mod)$r.squared,
  F_robusta=F_robusta, gl_numerador=q, gl_denominador=g-1, p_F_robusta=p_robusta,
  n_influyentes_cook=sum(cook>4/nrow(datos)))
write.csv(resumen_modelo,'output/tablas/03_regresion_resumen.csv',row.names=FALSE)
cat('FIN regresion. Ver output/tablas/03_*.csv\n')
