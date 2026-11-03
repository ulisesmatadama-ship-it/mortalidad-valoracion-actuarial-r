# Datos y fuentes

## Fuente declarada

La entrega académica identifica Human Mortality Database (HMD), Chile, año 2000,
ambos sexos. El CSV entregado contiene edades, muertes y un denominador `Total`;
no conserva una referencia al archivo HMD exacto ni la fecha de descarga.

HMD distingue sus estimaciones, publicadas bajo CC BY 4.0, de los datos de entrada,
que conservan las condiciones de sus proveedores. Por ello no se asigna una licencia
HMD automáticamente al CSV compilado. El archivo se conserva sin modificar dentro de este repositorio privado. Su inclusion
no se presenta como autorizacion para redistribucion publica; los graficos y resultados
documentan el uso academico y su fuente declarada.

- Condiciones: https://www.mortality.org/Data/UserAgreement
- Cita: https://www.mortality.org/Research/CitationGuidelines
- Disponibilidad de Chile: https://www.mortality.org/Data/DataAvailability
- Consulta de documentación: 2 de noviembre de 2026.

Referencia de la base: HMD. *Human Mortality Database*. Max Planck Institute for
Demographic Research (Germany), University of California, Berkeley (USA), y
French Institute for Demographic Studies (France). https://www.mortality.org/

## Obtener una entrada compatible

Solicitar a los autores el archivo y su referencia original, o descargar las series
correspondientes de HMD bajo sus condiciones. Documentar país, año, sexo, versión,
fecha y si el denominador representa personas al inicio o exposición en personas-año.
No mezclar series sólo por compartir nombres de columnas.

El pipeline acepta `edad`, `Muertes` y `Total`. Tener esas columnas permite ejecutar
el ejercicio, pero no demuestra que la aproximación probabilística sea apropiada.

## Ejemplo sin datos externos

`Rscript --vanilla scripts/ejecutar.R --demo` genera conteos binomiales ficticios con
denominadores enteros y semilla fija. Esa demo no representa mortalidad de Chile
ni sustituye al CSV académico.
