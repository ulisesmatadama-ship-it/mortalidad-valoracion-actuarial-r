source('R/mortalidad.R', encoding = 'UTF-8')
args <- commandArgs(trailingOnly = TRUE)
leer_opcion <- function(nm, defecto) {
  i <- match(nm, args)
  if (is.na(i)) return(defecto)
  if (i == length(args)) stop(paste('Falta valor para', nm), call. = FALSE)
  args[i + 1]
}
entrada <- leer_opcion('--datos', '')
es_demo <- !nzchar(entrada)
salida <- leer_opcion('--salida', if (es_demo) 'resultados/demo' else 'resultados/real')
nsim <- as.integer(leer_opcion('--nsim', '20000'))
dir.create(salida, recursive = TRUE, showWarnings = FALSE)
if (es_demo) {
  bruto <- datos_sinteticos()
} else {
  bruto <- leer_datos_csv(entrada)
}
ajuste <- ajustar_modelos(bruto)
sim <- simular_parametros(ajuste, nsim = nsim)
vp <- valorar(sim)
metricas <- medidas_riesgo(vp)
etiqueta <- if (es_demo) 'DATOS SINTETICOS' else 'CSV ACADEMICO PROPORCIONADO'
tabla <- data.frame(medida = names(metricas), valor = unname(metricas), origen = etiqueta)
write.csv(tabla, file.path(salida, 'metricas.csv'), row.names = FALSE)
comparacion <- rbind(
  data.frame(familia = 'LM_logit', modelo = names(ajuste$aic_lm), AIC = unname(ajuste$aic_lm)),
  data.frame(familia = 'GLM_binomial', modelo = names(ajuste$aic_glm), AIC = unname(ajuste$aic_glm)))
write.csv(comparacion, file.path(salida, 'modelos.csv'), row.names = FALSE)
coeficientes <- as.data.frame(coef(summary(ajuste$modelo)))
coeficientes$termino <- rownames(coeficientes)
rownames(coeficientes) <- NULL
write.csv(coeficientes, file.path(salida, 'coeficientes.csv'), row.names = FALSE)
graduada <- data.frame(edad = sim$edades,
  ajustada = as.numeric(fitted(ajuste$modelo)),
  mediana = apply(sim$q, 1, median),
  inferior_025 = apply(sim$q, 1, quantile, .025),
  superior_975 = apply(sim$q, 1, quantile, .975))
write.csv(graduada, file.path(salida, 'curva_graduada.csv'), row.names = FALSE)
write.csv(data.frame(modelo = ajuste$seleccionado, dispersion_Pearson = ajuste$dispersion_pearson,
  nsim = nsim, semilla = sim$semilla, edades = nrow(ajuste$datos), origen = etiqueta),
  file.path(salida, 'diagnostico.csv'), row.names = FALSE)
capture.output(sessionInfo(), file = file.path(salida, 'sessionInfo.txt'))
plot_mortalidad <- function() {
  par(mar = c(4.2, 4.5, 4, 1), family = 'sans')
  cruda <- ajuste$datos$ratio_observado
  lim <- range(c(cruda[cruda > 0], graduada$inferior_025, graduada$superior_975))
  plot(graduada$edad, graduada$ajustada, type = 'n', log = 'y', ylim = lim,
    xlab = 'Edad', ylab = 'Ratio observado / probabilidad aproximada',
    main = 'Graduacion de mortalidad | GLM academico')
  polygon(c(graduada$edad, rev(graduada$edad)),
    c(graduada$inferior_025, rev(graduada$superior_975)),
    col = '#D4E4ED', border = NA)
  points(ajuste$datos$edad, cruda, pch = 16, cex = .55, col = '#C47B3C')
  lines(graduada$edad, graduada$ajustada, col = '#19334B', lwd = 2)
  legend('topleft', c('Ratio observado', 'GLM', 'Banda parametrica nominal 95%'),
    col = c('#C47B3C', '#19334B', '#D4E4ED'), pch = c(16, NA, 15),
    lty = c(NA, 1, NA), bty = 'n', cex = .75)
  mtext(etiqueta, side = 3, line = .3, col = '#64748B', cex = .7)
}
plot_riesgo <- function() {
  par(mar = c(4.5, 4.5, 4, 1), family = 'sans')
  hist(vp / 1e6, breaks = 45, col = '#D4E4ED', border = 'white',
    xlab = 'Valor esperado descontado por escenario (millones de u.m.)',
    main = 'Incertidumbre parametrica del valor actuarial', ylab = 'Frecuencia')
  abline(v = metricas[1:3] / 1e6, col = c('#19334B', '#C47B3C', '#AD4050'),
    lwd = 2, lty = c(2, 1, 3))
  legend('topleft', c('Media (BEL academico)', 'VaR 99.5%', 'TVaR 99.5%'),
    col = c('#19334B', '#C47B3C', '#AD4050'), lwd = 2, lty = c(2, 1, 3), bty = 'n', cex = .75)
  mtext('No incluye riesgo de proceso ni constituye SCR regulatorio',
    side = 3, line = .3, col = '#64748B', cex = .7)
}
for (nombre in c('mortalidad', 'riesgo')) {
  dibujar <- if (nombre == 'mortalidad') plot_mortalidad else plot_riesgo
  png(file.path(salida, paste0(nombre, '.png')), width = 1400, height = 900, res = 160)
  dibujar(); dev.off()
  svg(file.path(salida, paste0(nombre, '.svg')), width = 8.5, height = 5.5)
  dibujar(); dev.off()
}
print(tabla, row.names = FALSE)
cat('Modelo:', ajuste$seleccionado, '\nDispersion Pearson:', ajuste$dispersion_pearson,
    '\nOrigen:', etiqueta, '\nSimulaciones:', nsim, '\n')
