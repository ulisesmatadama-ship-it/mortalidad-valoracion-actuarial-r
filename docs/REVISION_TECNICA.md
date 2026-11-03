# Revisión técnica y relación con la entrega

La entrega original se conserva localmente. El pipeline público es una adaptación
ejecutable en R base: facilita la revisión sin instalar una cadena de paquetes.
No se afirma que el HTML histórico haya sido regenerado de forma idéntica.

1. **Esquema.** Se corrige la referencia a una columna `Age` inexistente.
   La proyección identifica las edades por `match`, no por posición supuesta.
2. **Unidades.** El cociente muertes/`Total` se llama ratio observado. Si `Total`
   mide personas-año, ese cociente es una tasa central, no directamente `q_x`.
   Se conserva el GLM binomial con `floor(Total)` como aproximación académica
   del original. No se presenta ese redondeo como conversión actuarial válida.
3. **Modelos.** Se mantienen alternativas lineal, cuadrática y combinada, por
   separado para LM del logit y GLM binomial. Sus AIC se interpretan dentro de
   cada familia; no se comparan entre respuestas transformadas diferentes.
4. **Enfoque.** Los coeficientes se simulan con una normal asintótica centrada
   en su estimación y la covarianza del GLM. No hay prior ni posterior bayesiana.
   Una curva logit polinómica no es un ajuste explícito de la ley de Gompertz.
5. **Incertidumbre.** Se simulan parámetros, no fallecimientos individuales.
   Los cuantiles describen incertidumbre del valor esperado condicional, no
   la distribución completa de pérdidas de la cartera.
6. **Dispersion.** Se reporta el cociente Pearson/grados de libertad. Un valor
   elevado cuestiona la varianza binomial nominal; las bandas no se presentan
   como cobertura predictiva validada. No se implementa un modelo adicional.
7. **Valoración.** La prestación se paga al final del año de fallecimiento durante
   un plazo de 30 años, sin pago de supervivencia. Es un valor de prestaciones
   sin primas, gastos ni margen de riesgo: `BEL_academico` no es un BEL regulatorio completo.
8. **Capital.** Se reportan `VaR-BEL` y `TVaR-BEL` por separado. Ninguno se
   etiqueta como SCR regulatorio ni como garantía de solvencia.
9. **Colas.** La simulación actual usa 20,000 escenarios con semilla fija. A 99.5%
   hay alrededor de 100 observaciones de cola: no se garantiza precisión del
   cuantil ni convergencia sólo por aumentar el número. TVaR se calcula mediante
   promedio ponderado de la masa superior, evitando problemas con empates.

No se cambia el proyecto CAS ni se incorporan estos modelos al análisis del concurso.
