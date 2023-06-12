#Corregir simplificacion registral

#Librerias
library(data.table)
library(tidyverse)

#Cargar bases
files <- list.files(r'(C:\Users\Administrator\Desktop\CEP\Bases de datos\SP\Bases\Mi_simplificacion-organismos)',
                    pattern='*.txt',
                    full.names=T)
for(i in 1:length(files)){
  sp <- fread(files[i],sep=';')
  mes_trabajo <- str_remove(str_extract(files[i],'[0-9]+\\.txt'),'\\.txt')
  column <- colnames(sp)[1] # es igual agregar el [1] o no
  # el get es simplemente porq el nombre de la columna es muy largo, pero solo
  # le pide que cuente el patron de esa columna
  sp <- sp[,Cantidad_comas := str_count(get(column),'\\|')]
  # Elegir la cantidad de comas 
  t1 <- sp[,.(Cantidad = .N),by='Cantidad_comas']
  t1 <- t1[Cantidad == max(Cantidad)]
  t1 <- t1$Cantidad_comas
  sp <- sp[Cantidad_comas == t1]
  sp$Cantidad_comas <- NULL
  fwrite(sp,paste0(r'(C:\Users\Administrator\Desktop\CEP\Bases de datos\SP\Bases\Corregido\SP Corregido )',mes_trabajo,'.csv'))
  rm(sp) 
}