# Quedarme con el ultimo dato de simpreg que no tiene NULL de las relaciones laborales de MECTRA 2022-05

# Cargar librerias
library(tidyverse)
library(data.table)
library(fst)

#Cargar MECTRA
files_mectra <- list.files(r'(C:\Users\Administrator\Desktop\CEP\Bases de datos\MECTRA\FST\)',
                           pattern='*.fst',
                           full.names=T)
files_mectra <- files_mectra[str_detect(files_mectra,'m2021|m2022|m2023')]
full_mectra <- data.table()
for(i in 1:length(files_mectra)){
  mectra <- read_fst(files_mectra[i],
                     columns=c('cuit','cuil'),as.data.table=T)
  mectra <- mectra[,`:=`(cuil = as.double(cuil),
                         cuit = as.double(cuit))]
  full_mectra <- setDT(rbind(full_mectra,mectra))
  full_mectra <- unique(full_mectra)
}
uniqueN(full_mectra)
# Cargar datos 
files <- list.files(r'(C:\Users\Administrator\Desktop\CEP\Bases de datos\SP\Bases\Corregido)',
                    pattern='*.csv',
                    full.names=T)
data_final_sp <- data.table()
for(i in 1:length(files)){
  tmp <- fread(files[i],integer64='double',encoding='UTF-8',select = c('cuit','cuil','puesto_desem'))
  tmp <- tmp[,cuit := str_replace_all(cuit,'"',"")]
  tmp <- tmp[,cuil := str_replace_all(cuil,'"',"")]
  tmp <- tmp[,cuit := as.double(cuit)]
  tmp <- tmp[,cuil := as.double(cuil)]
  tmp <- tmp[!is.na(puesto_desem)]
  tmp <- merge(tmp,full_mectra,by=c('cuit','cuil'))
  mes_trabajo <- str_remove(str_extract(files[i],'[0-9]+\\.csv'),'\\.csv')
  tmp <- tmp[,mes := as.double(mes_trabajo)]
  data_final_sp <- setDT(rbind(data_final_sp,tmp))
  print(i)
}

#prueba <- data_final_sp[,. (cuil, cuit)]
#uniqueN(prueba) # tienen q quedar 11771461
setorder(data_final_sp, cuit, cuil, mes)
data_final_sp <- data_final_sp[, index:= 1:.N, by=c('cuit','cuil')]
data_final_sp <- data_final_sp[, maximo := max(index),by=c('cuit','cuil')]
data_final_sp <- data_final_sp[index == maximo] # q loco asi queda bien
data_final_sp$index <- NULL
data_final_sp$maximo <- NULL
data_final_sp$mes <- NULL
#Quedarme con data final
#data_final_sp <- data_final_sp[,Mes_final := max(mes),by=c('cuit','cuil')] 
  #data_final_sp <- data_final_sp[mes == Mes_final]
#data_final_sp$Mes_final <- NULL
#data_final_sp$mes <- NULL
data_final_sp <- unique(data_final_sp)

fwrite(data_final_sp,paste('CUIT CUIL desem - 2021 y 2022 - ',Sys.Date(),'.csv',sep=''))
