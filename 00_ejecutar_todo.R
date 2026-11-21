# GRUPO 20 - EJECUTAR EN ORDEN DESDE LA RAIZ DEL PROYECTO
# En RStudio: abrir proyecto.Rproj, e iniciar source('script/00_ejecutar_todo.R')
source('utils/funciones_comunes.R', encoding='UTF-8')
verificar_raiz()
preparar_carpetas()
verificar_paquetes(c('lmtest','sandwich','cluster','ggplot2'))
orden <- c('01_preparacion.R', '02_descriptivos_concentracion.R',
           '03_regresion.R','04_clustering.R','05_graficos.R','06_control_calidad.R')
for (archivo in orden) {
  cat('\n\n==========',archivo,'==========\n')
  source(file.path('script',archivo),encoding='UTF-8',chdir=FALSE)
}
cat('\nCOMPLETO. Revisar output/tablas/ y output/graficos/.\n')
