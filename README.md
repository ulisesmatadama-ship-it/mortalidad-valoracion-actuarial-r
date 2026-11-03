# Graduación de mortalidad y valoración actuarial en R

Proyecto académico en equipo: **LM sobre logit, GLM binomial, simulación
paramétrica y valoración de prestaciones de fallecimiento**.
Portafolio de **Ulises Matadama Lara**.

> **Repositorio privado con el CSV académico original.** Antes de hacerlo público,
> revisar procedencia, condiciones de difusión y autoría colectiva.

## Qué contiene

- CSV original, conservado sin modificaciones.
- Pipeline ejecutable en R base, con semilla fija y sin instalar paquetes.
- Comparación de especificaciones, curva graduada, diagnóstico y medidas de riesgo.
- Resultados recalculados y conciliación explícita con el informe histórico.
- Pruebas locales y workflow de GitHub Actions.

![Graduación de mortalidad](resultados/real/mortalidad.png)

## Ejecutar el proyecto completo

Requiere **R 4.5.1 o compatible**. Desde la raíz del repositorio:

```sh
Rscript --vanilla scripts/ejecutar.R
Rscript --vanilla tests/verificar.R
```

La ejecución principal utiliza `data/academico/datos_equipo1.csv` y actualiza
`resultados/real/`. No genera datos para sustituir esa entrada.

Opcionalmente se puede indicar otro CSV o ejecutar una prueba con datos sintéticos:

```sh
Rscript --vanilla scripts/ejecutar.R --datos ruta/al/archivo.csv --salida resultados/local
Rscript --vanilla scripts/ejecutar.R --demo
```

La demo opcional produce `resultados/demo/`, etiquetados por separado.

## Datos, método y supuestos

La fuente declarada en la entrega es HMD, Chile, año 2000, ambos sexos.
Se seleccionan edades 20–99 y se comparan términos lineal, cuadrático y combinado,
por separado para LM del logit y GLM binomial.

Se conserva la aproximación binomial del ejercicio, que redondea `Total`.
Si ese denominador representa personas-año, muertes/Total es una tasa central y
no directamente una probabilidad anual. El redondeo no resuelve esa diferencia
de unidades; la limitación se documenta en vez de presentar el ajuste como definitivo.

Se simulan coeficientes bajo una normal asintótica con 20,000 escenarios y semilla
12345. No es una posterior bayesiana ni una simulación de fallecimientos individuales.

La valoración supone 1,000 asegurados de edad 25, plazo de 30 años, prestación de
300,000 unidades monetarias al final del año de fallecimiento y descuento supuesto
de 4.4%. La entrega expresaba la prestación en UDIS; no se hace conversión a pesos.

## Resultados y conciliación

El GLM combinado reproduce los coeficientes y AIC del informe histórico.
La valoración histórica de prestaciones no se reproduce con la edad y el plazo
documentados. Aquí se presentan las cifras recalculadas, sin reemplazar
silenciosamente el resultado anterior. Consultar [resultados explicados](docs/RESULTADOS.md).

Se reportan media del valor de prestaciones (`BEL_academico`), VaR y TVaR de la
incertidumbre paramétrica y sus excesos sobre la media. No son un BEL regulatorio
completo ni un SCR regulatorio y no garantizan solvencia.

![Valor actuarial](resultados/real/riesgo.png)

## Archivos principales

| Ruta | Contenido |
|---|---|
| `data/academico/` | CSV original y procedencia |
| `R/mortalidad.R` | Datos, modelos, simulación y valoración |
| `scripts/ejecutar.R` | Pipeline reproducible |
| `tests/verificar.R` | Identidad actuarial, escala, cola y reproducibilidad |
| `resultados/real/` | CSV, gráficos y entorno de la ejecución principal |
| `resultados/demo/` | Prueba sintética opcional y diferenciada |
| `docs/` | Revisión, resultados, procedencia y créditos |

## Autoría y fuentes

Trabajo original de Carlos Cárdenas Osorio, Diego Uriel Hernández Sotelo,
Ulises Matadama Lara y Samuel Arias García. Se reconoce autoría colectiva.

- [Créditos](docs/CREDITOS.md).
- [Revisión técnica](docs/REVISION_TECNICA.md).
- [Datos y fuentes](docs/DATOS_Y_FUENTES.md).
- [Verificación](docs/VERIFICACION.md).
- [Human Mortality Database](https://www.mortality.org/).
- [Documentación de GLM en R](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/glm.html).

No se afirma una graduación explícita de Gompertz ni una estimación bayesiana
que el código no implementa. Las bandas son nominales y requieren considerar
el diagnóstico de dispersión antes de interpretarlas.
