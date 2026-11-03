# Adaptacion reproducible del ejercicio academico. No es un modelo regulatorio.
leer_datos_csv <- function(ruta) {
  if (!file.exists(ruta)) stop('No se encontro el CSV.', call. = FALSE)
  bytes <- readBin(ruta, what = 'raw', n = file.info(ruta)$size)
  if (length(bytes) >= 3 && identical(as.integer(bytes[1:3]), c(239L,187L,191L)))
    bytes <- bytes[-(1:3)]
  texto <- rawToChar(bytes)
  if (!nzchar(texto)) stop('El CSV esta vacio.', call. = FALSE)
  utf8 <- !is.na(iconv(texto, from = 'UTF-8', to = 'UTF-8', sub = NA))
  codificacion <- if (utf8) 'UTF-8' else 'latin1'
  texto <- iconv(texto, from = codificacion, to = 'UTF-8')
  d <- read.csv(text = texto, encoding = 'UTF-8', check.names = FALSE)
  attr(d, 'codificacion') <- codificacion
  d
}

preparar_datos <- function(d) {
  requeridas <- c('edad', 'Muertes', 'Total')
  if (!is.data.frame(d) || !all(requeridas %in% names(d)))
    stop('Se requieren edad, Muertes y Total.', call. = FALSE)
  edad_texto <- as.character(d$edad)
  edad <- suppressWarnings(as.integer(edad_texto))
  conservar <- !is.na(edad) & grepl('^[0-9]+$', edad_texto) & edad >= 20 & edad <= 99
  d <- d[conservar, requeridas, drop = FALSE]
  d$edad <- edad[conservar]
  d <- d[order(d$edad), , drop = FALSE]
  if (nrow(d) < 5 || anyDuplicated(d$edad))
    stop('Se requiere una fila por edad y al menos cinco edades.', call. = FALSE)
  if (!is.numeric(d$Muertes) || !is.numeric(d$Total) ||
      any(!is.finite(d$Muertes)) || any(!is.finite(d$Total)) ||
      any(d$Muertes < 0) || any(d$Muertes != floor(d$Muertes)) ||
      any(d$Total <= 0) || any(d$Muertes > floor(d$Total)))
    stop('Conteos o denominadores invalidos.', call. = FALSE)
  # Conserva la aproximacion del original: no identifica personas-ano con personas.
  d$expuestos <- floor(d$Total)
  d$ratio_observado <- d$Muertes / d$Total
  d$edad_c <- (d$edad - mean(d$edad)) / 10
  d
}

ajustar_modelos <- function(d) {
  d <- preparar_datos(d)
  glms <- list(
    lineal = glm(cbind(Muertes, expuestos - Muertes) ~ edad_c,
                 family = binomial(), data = d),
    cuadratico = glm(cbind(Muertes, expuestos - Muertes) ~ I(edad_c^2),
                    family = binomial(), data = d),
    lineal_cuadratico = glm(cbind(Muertes, expuestos - Muertes) ~ edad_c + I(edad_c^2),
                          family = binomial(), data = d))
  aic <- vapply(glms, AIC, numeric(1))
  nombre <- names(which.min(aic))
  modelo <- glms[[nombre]]
  if (!modelo$converged || any(!is.finite(coef(modelo))))
    stop('El GLM no convergio.', call. = FALSE)
  # Para el logit observado se usan solo ratios estrictamente dentro de (0,1).
  dl <- d[d$ratio_observado > 0 & d$ratio_observado < 1, , drop = FALSE]
  dl$logit_observado <- qlogis(dl$ratio_observado)
  lms <- list(
    lineal = lm(logit_observado ~ edad_c, data = dl),
    cuadratico = lm(logit_observado ~ I(edad_c^2), data = dl),
    lineal_cuadratico = lm(logit_observado ~ edad_c + I(edad_c^2), data = dl))
  list(datos = d, modelo = modelo, seleccionado = nombre,
       aic_glm = aic, aic_lm = vapply(lms, AIC, numeric(1)),
       dispersion_pearson = sum(residuals(modelo, type = 'pearson')^2) / df.residual(modelo))
}

simular_parametros <- function(ajuste, nsim = 20000L, semilla = 12345L) {
  if (length(nsim) != 1 || !is.finite(nsim) || nsim < 1000 || nsim != floor(nsim))
    stop('Use al menos 1000 simulaciones enteras.', call. = FALSE)
  set.seed(semilla)
  b <- coef(ajuste$modelo)
  V <- vcov(ajuste$modelo)
  U <- chol(V)
  Z <- matrix(rnorm(nsim * length(b)), nrow = nsim)
  B <- sweep(Z %*% U, 2, b, '+')
  X <- model.matrix(ajuste$modelo)
  q <- plogis(X %*% t(B))
  # Normal asintotica de coeficientes; NO posterior bayesiana ni simulacion de muertes.
  list(q = q, beta = B, edades = ajuste$datos$edad, semilla = semilla, nsim = nsim)
}

valorar <- function(sim, edad_inicial = 25L, horizonte = 30L,
                    suma_asegurada = 300000, asegurados = 1000, tasa = .044) {
  p <- c(edad_inicial, horizonte, suma_asegurada, asegurados, tasa)
  if (any(!is.finite(p)) || edad_inicial != floor(edad_inicial) ||
      horizonte != floor(horizonte) || asegurados != floor(asegurados) ||
      horizonte < 1 || suma_asegurada <= 0 || asegurados < 1 || tasa <= -1)
    stop('Supuestos de cartera invalidos.', call. = FALSE)
  edades <- edad_inicial + seq_len(horizonte) - 1L
  idx <- match(edades, sim$edades)
  if (anyNA(idx)) stop('Faltan edades del horizonte solicitado.', call. = FALSE)
  if (!is.matrix(sim$q) || nrow(sim$q) != length(sim$edades) ||
      any(!is.finite(sim$q)) || any(sim$q < 0 | sim$q > 1))
    stop('Probabilidades simuladas invalidas.', call. = FALSE)
  vivo <- rep(1, ncol(sim$q)); vp <- rep(0, ncol(sim$q))
  for (t in seq_len(horizonte)) {
    q <- sim$q[idx[t], ]
    vp <- vp + vivo * q * suma_asegurada / (1 + tasa)^t
    vivo <- vivo * (1 - q)
  }
  vp * asegurados
}

medidas_riesgo <- function(vp, nivel = .995) {
  if (length(vp) < 2 || any(!is.finite(vp)) || nivel <= 0 || nivel >= 1)
    stop('Distribucion o nivel invalido.', call. = FALSE)
  bel <- mean(vp)
  var <- unname(quantile(vp, nivel, type = 7))
  # Promedio ponderado de la masa superior, incluyendo fraccion de observacion.
  # Evita cola vacia o perder empates cuando la distribucion es discreta.
  y <- sort(vp, decreasing = TRUE)
  masa <- length(y) * (1 - nivel)
  pesos <- pmin(1, pmax(0, masa - (seq_along(y) - 1)))
  tvar <- sum(pesos * y) / masa
  c(BEL_academico = bel, VaR_995 = var, TVaR_995 = tvar,
    exceso_VaR_BEL = var - bel, exceso_TVaR_BEL = tvar - bel)
}

datos_sinteticos <- function(semilla = 918L) {
  set.seed(semilla)
  edad <- 20:99
  Total <- round(280000 * exp(-.045 * (edad - 20)))
  p <- plogis(-7.4 + .075 * (edad - 20) + .00022 * (edad - 20)^2)
  data.frame(edad = edad, Muertes = rbinom(length(edad), Total, p), Total = Total)
}
