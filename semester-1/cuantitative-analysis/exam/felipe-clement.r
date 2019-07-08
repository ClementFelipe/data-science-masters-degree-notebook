library(xts)
library(car)
library(xts)
library(olsrr)
library(ggplot2)
library(lmtest)
library(tseries)
library(AER)
library(sandwich)
library(lm.beta)
library(ggplot2)

# # Resultados
# 
# Para el [dataset](https://archive.ics.uci.edu/ml/datasets/Bike+Sharing+Dataset) de bicicletas alquiladas por hora, estimamos mediante una regresión lineal multiple usando el metodo de Minimos Cuadrados Ordinarios (MCO) un modelo que explica la cantidad de bicicletas alquiladas en un día dado en un 84%.
# 
# Entre las variables del dataset, se encuentra que las variables mas relevantes (en orden) el año y la temperatura en el día. De este resultado, podemos intuir que tiene sentido que el año sea la variable mas relevante, pues mediante pasa el tiempo, se espera que las empresas que operan bajo esta modalidad logren una mayor penetración del mercado. Por otro lado, la temperatura del día es la segunda variable mas relevante, esta a su vez tendría sentido que dependa de como cambia el clima durante el año.
# 
# # Procedimiento
# 
# Para llegar a los resultados anteriores, se realizó una limpieza a los datos, seguido de una selección automatica de modelo, analisis de supuestos (y corrección) y finalmente un calculo de los coeficientes mas relevantes.
# 
# ## Exploración de los datos
# 
# ### Carga de los datos
# 
# El dataset cargado contiene 16 variables y 731 observaciones, algunos de sus campos son irrelevantes, de tipo incorrecto, en unidades no interpretables y presentan multicolinealidad perfecta, se procedió a transformar el dataset para ser utilizable en la creación del modelo. La forma inicial de los datos es como sigue:
  
data_raw <- read.csv("data.csv")
str(data_raw)
head(data_raw, 1)

# ### Limpieza de los datos
# 
# Se realizan las siguientes operaciones sobre los datos:
#   
#   * Las columnas `instant` y `dteday` indican el indice de los datos, debido a que `instant` carece de semantica, será eliminada, y `dteday` se conserva como nombre de cada fila del dataset
# * Las variables categoricas `season`, `yr`, `month`, `holiday`, `weekday`, `workingday`, `weathersit` se cargan como numeros enteros, y se transforman a factores
# * Las siguientes variables numericas se cargan normalizadas, lo cual dificulta su interpretación, por ende se de-normalizan de la siguiente manera:
#   * temp: temp*(tM-tm) + tm, tm = -8, tM = 39
# * atemp: atemp*(tM-tm) + tm, tm = -16, tM = 50
# * hum: hum * 100
# * windspeed: windspeed * 67
# 
# Estas transformaciones resultan en el siguiente dataset:
  
row.names(data_raw) <- data_raw$dteday
data_1 <- data_raw[, -which(colnames(data_raw) %in% c("instant", "dteday"))]

data_1$season <- as.factor(data_1$season)
data_1$yr <- as.factor(data_1$yr)
data_1$mnth <- as.factor(data_1$mnth)
data_1$holiday <- as.factor(data_1$holiday)
data_1$weekday <- as.factor(data_1$weekday)
data_1$workingday <- as.factor(data_1$workingday)
data_1$weathersit <- as.factor(data_1$weathersit)

t_min <- -8
t_max <- 39

data_1$temp <- data_1$temp * (t_max - t_min) + t_min

t_min <- -16
t_max <- 50

data_1$atemp <- data_1$atemp * (t_max - t_min) + t_min

data_1$hum <- data_1$hum * 100
data_1$windspeed <- data_1$windspeed * 67

head(data_1, 1)

# ### Supuestos Parte 1 - Multicolinealidad perfecta
# 
# Observando los datos, se encuentra un primer caso de multicolinealidad perfecta entre las variables `casual`, `registered` y `cnt` debido a que `casual` + `registered` = `cnt`, se eliminan ambas columnas, pues su efecto es capturado en `cnt` y conservar alguna de las dos sería incorrecto, pues parte de la variable objetivo estaría entre las variables explicativas del dataset.

data_2 <- data_1[, -which(colnames(data_1) %in% c("casual", "registered"))]

alias(lm(cnt ~ ., data = data_2))

# Se revisa multicolinealidad perfecta entre las variables categoricas, observamos que existe multicolinealidad perfecta entre `workingday` y `weekday`, procedemos a eliminar `workingday`, pues esta puede ser calculada por la combinacion lineal de `weekday` y `holiday`. De esta manera, obtenemos el dataset final:
  
data <- data_2[, -which(colnames(data_2) == "workingday")]
head(data, 1)

# ## Seleccion del modelo
# 
# Se selecciona un modelo explorando todos los posibles bajo los criterios AIC, BIC y R2-Ajustado. Estos criterios seleccionan modelos con las siguientes variables (respectivamente):
#   
#   * season, yr, mnth, holiday, weekday, weathersit, temp, hum, windspeed
# * season, yr, mnth, holiday, weathersit, temp, hum, windspeed

model <- lm(cnt ~ ., data = data)
models <- ols_step_all_possible(model)

models$predictors[which.min(models$aic)]
models$predictors[which.min(models$sbc)]
models$predictors[which.max(models$predrsq)]

# AIC y R2 ajustado sugieren el modelo usando las variables `season`, `yr`, `mnth`, `holiday`, `weekday`, `weathersit`, `temp`, `hum`, `windspeed`, mientras que BIC sugiere un modelo similar, a excepción de la variable `weekday`.

model_1_vars <- strsplit(models$predictors[which.min(models$aic)], " ")[[1]]
model_2_vars <- strsplit(models$predictors[which.min(models$sbc)], " ")[[1]]

model_1_formula <- paste("cnt ~", paste(model_1_vars, collapse = " + "))
model_2_formula <- paste("cnt ~", paste(model_2_vars, collapse = " + "))

model_1 <- lm(model_1_formula, data)
model_2 <- lm(model_2_formula, data)

# Estos dos modelos son los candidatos para explicar las ventas diarias de bicicletas. Para escoger uno de los dos, se deben comparar empleando una prueba estadistica, sin embargo, es necesario evaluar los supuestos del teorema de Gauss-Markov primero, y aplicar correcciones necesarias. 
# 
# Se probaran primero los supuestos sobre el error (homoscedasticidad y no-autocorrelacion) con el proposito de poder aplicar pruebas para comparar ambos modelos y evaluar si es posible remover variables con multicolinealidad.
# 
# ### Homoscedasticidad
# 
# Se prueba si los errores siguen una distribución normal, con el proposito de decidir si la prueba de Breusch-Pagan es aplicable, de modo contrario, se utilizaría la versión studentizada.

ols_test_normality(model_1)
ols_test_normality(model_2)

# Para todas las pruebas empleadas (con un nivel de confianza del 99%), en ambos modelos, los errores no siguen una distribucion normal.

# #### Pruebas
# 
# Se construye una tabla para validar dos pruebas de autocorrelación (Breusch-Pagan, White), en esta se presentan los p-valor de las pruebas, todas con la hipotesis nula de homoscedasticidad.

breusch_pagan <- c(
  bptest(model_1)$p.value,
  bptest(model_2)$p.value
)

row_names <- c("Model 1", "Model 2")
consolidated_h_tests <- data.frame(breusch_pagan, row.names = row_names)
head(consolidated_h_tests)

# Los resultados de las pruebas a ambos modelos indican con un nivel de confianza del 99% que existe heteroscedasticidad causada por todas las variables del respectivo modelo.
# 
# ### Autocorrelacion
# 
# Para decidir que corrección tomar hacia los problemas de heteroscedasticidad y no-autocorrelación, se realizan primero las pruebas de autocorrelación, de esta manera, se utilizaría un estimador de la matriz de varianzas y covarianzas de los coeficientes consistente ante heteroscedasticidad y autocorrelación (HAC).
# 
# #### Pruebas
# 
# Se construye una tabla para validar cuatro pruebas de autocorrelación (Rachas, Durbin-Watson, Box-Ljung, Breusch-Godfrey), en esta se presentan los p-valor de las pruebas, todas con la hipotesis nula de no-autocorrelación.

runs_test <- function(mod) {
  errs <- residuals(mod)
  errs_signs <- factor(errs > 0)
  runs.test(errs_signs)
}

runs <- c(
  runs_test(model_1)$p.value,
  runs_test(model_2)$p.value
)

durbin_watson <- c(
  dwtest(model_1)$p.value,
  dwtest(model_2)$p.value
)

box_test <- c(
  Box.test(residuals(model_1))$p.value,
  Box.test(residuals(model_2))$p.value
)

breusch_godfrey <- c(
  bgtest(model_1)$p.value,
  bgtest(model_2)$p.value
)

row_names <- c("Model 1", "Model 2")
consolidated_tests <- data.frame(runs, durbin_watson, box_test, breusch_godfrey, row.names = row_names)
head(consolidated_tests)

# (la tabla anterior aproxima los p-valores de las pruebas a 0, puesto que son muy cercanos a 0)
# 
# Para ambos modelos, con un nivel de confianza del 99% podemos rechazar la `H0: homoscedasticidad`, donde se concluye que la heteroscedasticidad es causada por todas las variables. Vale la pena notar:
#   
#   * No es necesaria la prueba h de Durbin, pues no existe variable explicativa rezagada.
# * No es necesaria la prueba de Ljung-Box, pues la muestra es mayor a 20.
# 
# ### Correccion para heteroscedasticidad y autocorrelacion
# 
# Utilizamos los 3 metodos HAC (Newey-West, Andrews, Lumley-Hagerty) para re-estimar la matriz de varianzas y covarianzas de los coeficientes y comparar los dos modelos candidato. Comparamos los dos modelos mediante una prueba de Wald donde la hipotesis nula implica el modelo sin `weekday`.

cov_matrix_nw <- NeweyWest(model_1)
cov_matrix_an <- kernHAC(model_1)
cov_matrix_lh <- weave(model_1)

wald_p_value <- c(
  waldtest(model_2, model_1, vcov = cov_matrix_nw)[[4]][2],
  waldtest(model_2, model_1, vcov = cov_matrix_an)[[4]][2],
  waldtest(model_2, model_1, vcov = cov_matrix_lh)[[4]][2]
)

row_names <- c("Newey-West", "Andrews", "Lumley-Heagerty")
consolidated_auto <- data.frame(wald_p_value, row.names = row_names)
head(consolidated_auto)

model <- model_1

# Para todas las pruebas, podemos rechazar con un nivel de confianza del 99% la hipotesis nula de que el modelo restringido es mejor, por lo tanto, se escoge el modelo con la variable `weekday`.
# 
# ### Multicolinealidad
# 
# Se analiza el modelo resultante para detectar multicolinealidad mediante el factor de inflación de la varianza y la prueba de Belsley-Kuh-Welsh (Kappa).
# 
# #### VIF
# 
# Se calcularan los VIF para cada uno de los coeficientes del modelo.

vif(model)[,1]

# El VIF para el coeficiente de las variables `mnth` y `season` son de 391 y 169 respectivamente, estas variables son candidato a ser removidas.
# 
# #### Kappa
# 
# Se calcula el valor de la prueba Kappa para multicolinealidad.

calculate_kappa <- function(mod) {
  X <- model.matrix(mod)
  eigenvalues <- eigen(t(X) %*% X)
  
  eigen_max <- max(eigenvalues$val)
  eigen_min <- min(eigenvalues$val)
  
  return(sqrt(eigen_max / eigen_min))
}

calculate_kappa(model)

# Esta prueba resulta en un valor de grande de 1651, removeremos `mnth` y probaremos si se reduce el problema de multicolinealidad.
# 
# #### Solución

model_res_1 <- lm(cnt ~ season + yr + holiday + weekday + weathersit + temp + hum + windspeed, data)
vif(model_res_1)[,1]
calculate_kappa(model_res_1)

model <- model_res_1

# Se observa que eliminando `mnth` todos los VIF de los coeficientes son menores que 4, lo cual parece indicar que no hay multicolinealidad, sin embargo, el valor de la prueba Kappa sigue siendo 611, una reducción drastica del valor anterior.

model_res_2 <- lm(cnt ~ yr + holiday + weekday + weathersit + temp + hum + windspeed, data)
vif(model_res_2)[,1]
calculate_kappa(model_res_2)

# Si eliminamos el siguente valor el VIF mas grande `season`, todos los coeficientes tendrán un VIF menor a 2, y el valor de la prueba Kappa no disminuye demasiado (607). Por este motivo, basta con eliminar solamente `mnth` ya que el efecto de tratar de reducir mas el valor de la prueba Kappa es marginal y todos los VIF son menores a 4.
# 
# ## Modelo final
# 
# Se prueba otra vez los supuestos de heteroscedasticidad y autocorrelacion. Este modelo presenta heteroscedasticidad y autocorrelacion todavía, por lo tanto, se re-estima la matriz de varianzas y covarianzas basado en el metodo de Lumley-Heagerty.

# heteroscedasticidad
bptest(model)

# autocorrelacion
runs_test(model)
dwtest(model)
Box.test(residuals(model))
bgtest(model)

cov_matrix <- weave(model)

# ## Variable mas relevante
# 
# Se procede a encontrar los coeficientes estandarizados del modelo, con el proposito de encontrar cual es la variable mas relevante. Se encuentra que la variable mas relevante es `yr` y luego `temp`.

model_s <- lm.beta(model)

estimated_coefficients <- matrix(0,16,2)

variable_names  <- names(model_s$standardized.coefficients)[-1]
estimated_coefficients <- matrix(model_s$standardized.coefficients[-1])
standard_coefficients <- as.data.frame(variable_names)
standard_coefficients$coef.est <- estimated_coefficients 

p <- ggplot(data=standard_coefficients, aes(x=variable_names, y=estimated_coefficients)) +
  geom_bar(stat="identity", fill="steelblue") + 
  ggtitle("Coeficientes estandarizados")
p + coord_flip()

