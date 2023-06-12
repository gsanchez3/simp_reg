# Desestacionalizar salarios 
salarios_desestacionalizados <- tibble()
for(i in unique(salario$letra)){
  tmp <- salario %>% filter(letra == i)
  diferencia <- salario %>% filter(letra == i)
  diferencia <- diferencia$w_mean
  diferencia <- ts(diferencia,start=c(2007),frequency=12)
  #Descomponer con RJDemetra
  descomposicion <- RJDemetra::x13(diferencia)
  # Llevar el resultado a dataframe
  df <- data.frame(.preformat.ts(descomposicion$final$series), stringsAsFactors = FALSE)
  # Pasar el nombre de las filas a variable
  df <- df %>% tibble::rownames_to_column(var = 'fecha')
  # Dar formato de fecha
  df <- df %>% 
    mutate(fecha = lubridate::my(fecha))
  # Seleccionar columnas deseadas
  df <- df %>% 
    select(fecha,sa,t) %>% 
    mutate(letra = i)
  # Unir datos 
  tmp <- tmp %>% 
    left_join(df,by=c('fecha','letra'))
  salarios_desestacionalizados <- union_all(salarios_desestacionalizados,tmp)
}