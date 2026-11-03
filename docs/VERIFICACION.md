# Verificación local

Fecha: 2 de noviembre de 2026. Entorno: R 4.5.1 en Windows.

Se ejecutaron `tests/verificar.R` y `scripts/ejecutar.R`. Se revisaron los gráficos
generados y las rutas de los enlaces del README. El workflow incluido vuelve a
ejecutar las pruebas y la demo en GitHub Actions; su resultado remoto se informa
separadamente y no se presupone a partir del resultado local.

La valoración se contrastó con una identidad analítica de mortalidad constante,
escalamiento por tamaño de cartera y cobertura completa de edades. Se comprobaron
empates en TVaR, lectura de CSV con BOM/Latin-1 y reproducibilidad con semilla fija.
La corrida del CSV académico reprodujo el ajuste GLM del HTML, pero no su antigua
valoración de prestaciones; ver `RESULTADOS.md`.
