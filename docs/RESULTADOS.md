# Resultados recalculados y conciliación con el informe histórico

Ejecución local: R 4.5.1, semilla 12345, 20,000 simulaciones. CSV proporcionado
por el autor el 2 de noviembre de 2026. La fecha es de recepción, no de descarga HMD.

## Ajuste de mortalidad

- 80 edades analizadas: 20–99.
- Selección: GLM con término lineal y cuadrático en edad centrada por décadas.
- AIC GLM: **1005.190642**, que coincide con el 1,005.19 del informe histórico.
- Dispersión de Pearson / grados de libertad: **4.345837**.

Los coeficientes del GLM coinciden con los publicados en la entrega al redondeo
mostrado. La dispersión cuestiona la varianza binomial nominal: un buen ajuste visual
o menor AIC no acredita el modelo probabilístico completo ni la cobertura de las bandas.

## Valoración académica

Edad 25; horizonte de 30 años, edades 25–54; 1,000 asegurados; prestación de 300,000
unidades monetarias al final del año de fallecimiento; descuento supuesto de 4.4%.

| Medida | Recalculado (u.m.) | Informe histórico (u.m., no reproducido) |
|---|---:|---:|
| Media de valoraciones / BEL académico | 9,121,666.53 | 51,304,858 |
| VaR 99.5% paramétrico | 9,296,537.33 | 51,803,882 |
| TVaR 99.5% paramétrico | 9,317,751.16 | 51,855,607 |
| Exceso VaR sobre media | 174,870.80 | 499,024 |
| Exceso TVaR sobre media | 196,084.63 | 550,749 |

**La valoración histórica no queda reproducida.** El código histórico referencia
`datos$Age`, columna que no existe en el CSV recibido. La adaptación identifica
explícitamente las edades por su valor y verifica que se proyecten 25–54.
El informe original y su fuente se conservan fuera del repositorio público.

No se atribuye toda la diferencia a ese defecto sin una reproducción de la versión
que generó el HTML. Tampoco se explica como simple redondeo o cambio de semilla.
Las cifras públicas del pipeline son las recalculadas; la tabla mantiene transparente
la diferencia para no trasladar al portafolio una cifra histórica sin conciliar.

La simulación modifica parámetros, no realiza fallecimientos aleatorios. Las medidas
son de la distribución del valor esperado condicional, no del riesgo total de la cartera.
Ni el exceso VaR ni el exceso TVaR se denominan SCR regulatorio.

## Integridad y reproducción

SHA-256 del CSV utilizado:

```text
a764ab7fff73be00117d5502ac359da4219586822d472b02b9d98f38beca4223
```

Las tablas de `resultados/real/` y sus gráficos se regeneran desde ese archivo con
`scripts/ejecutar.R`. Los resultados sintéticos de `resultados/demo/` son distintos
y están identificados como tales. Ver `sessionInfo.txt` para el entorno local.
