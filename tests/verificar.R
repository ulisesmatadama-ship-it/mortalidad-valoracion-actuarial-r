source('R/mortalidad.R', encoding = 'UTF-8')
falla <- function(expr) inherits(try(force(expr), silent = TRUE), 'try-error')
# Lectura robusta de BOM y de encabezados Latin-1 sin cambiar el archivo fuente.
tmp <- tempfile(fileext = '.csv')
contenido <- charToRaw('edad,Muertes,Total\n25,1,100\n')
writeBin(c(as.raw(c(239,187,191)), contenido), tmp)
stopifnot(identical(names(leer_datos_csv(tmp)), c('edad','Muertes','Total')))
writeBin(c(charToRaw('A'), as.raw(241), charToRaw('o,edad,Muertes,Total\n2000,25,1,100\n')), tmp)
stopifnot(leer_datos_csv(tmp)$edad == 25)
unlink(tmp)
# Identidad actuarial con mortalidad constante y prestacion al final del ano.
q <- .01; h <- 10; r <- .03
sim <- list(edades = 25:34, q = matrix(q, nrow = 10, ncol = 4))
v <- valorar(sim, horizonte = h, suma_asegurada = 100, asegurados = 1, tasa = r)
esperado <- sum((1 - q)^(0:9) * q * 100 / (1 + r)^(1:10))
stopifnot(max(abs(v - esperado)) < 1e-12)
stopifnot(max(abs(valorar(sim, horizonte = h, suma_asegurada = 100,
                        asegurados = 5, tasa = r) - 5 * v)) < 1e-10)
stopifnot(falla(valorar(sim, horizonte = 11)))
# La cola de una distribucion constante es la constante, no NA.
m <- medidas_riesgo(rep(100, 1000))
stopifnot(all(m[1:3] == 100), all(m[4:5] == 0))
stopifnot(medidas_riesgo(1:1000)[3] >= medidas_riesgo(1:1000)[2])
d <- datos_sinteticos(); a <- ajustar_modelos(d)
s <- simular_parametros(a, nsim = 1000)
stopifnot(all(s$q > 0 & s$q < 1), nrow(s$q) == 80)
stopifnot(identical(s$q, simular_parametros(a, nsim = 1000)$q))
d$Total[1] <- 0
stopifnot(falla(ajustar_modelos(d)))
stopifnot(falla(simular_parametros(a, nsim = 0)))
cat('Mortalidad: identidad actuarial, escala, cola, cobertura de edades y reproducibilidad verificadas.\n')
