---
name: code-auditing
description: Skill de proyecto orientado a tareas.
version: 1.0.0
---
# Skill de Auditoría de Código

Metodología integral para auditorías sistemáticas de calidad de código.

## Cuándo usarlo

- Auditorías integrales de calidad de código
- Evaluaciones de vulnerabilidades de seguridad
- Identificación de deuda técnica
- Revisiones de código previas a un release
- Verificación de buenas prácticas
- Auditorías de librerías y dependencias

## Fases de la auditoría

### Fase 0: Configuración previa al análisis
1. Revisar los archivos de configuración del proyecto (package.json, tsconfig.json, etc.)
2. Identificar el stack tecnológico y las principales librerías
3. Revisar configuraciones de linting/formato
4. Ejecutar los comandos de linting/testing existentes como línea base
5. Cargar la documentación de las librerías core identificadas

### Fase 1: Descubrimiento
1. Encontrar todos los archivos de código por tipo
2. Crear una lista de seguimiento para cada archivo
3. Agrupar archivos por módulo/funcionalidad para el análisis contextual

### Fase 2: Análisis archivo por archivo
Para cada archivo, analizar:
- Código muerto (funciones, variables, imports sin usar)
- Code smells y anti-patrones
- Implementaciones personalizadas que podrían usar librerías establecidas
- Vulnerabilidades de seguridad
- Problemas de rendimiento
- Patrones desactualizados o APIs obsoletas
- Manejo de errores faltante
- Funciones excesivamente complejas
- Código duplicado

### Fase 3: Verificación de buenas prácticas
Para cada librería y framework:
1. Obtener la documentación oficial
2. Comparar la implementación contra los patrones oficiales
3. Identificar desviaciones respecto de las recomendaciones
4. Anotar patrones de uso desactualizados
5. Marcar anti-patrones desaconsejados

### Fase 4: Detección de patrones
Buscar problemas recurrentes:
- Anti-patrones comunes entre archivos
- Lógica duplicada que podría abstraerse
- Estilos de código inconsistentes
- Patrones de manejo de errores faltantes

### Fase 5: Recomendaciones de librerías
Para implementaciones personalizadas:
1. Verificar si las librerías actuales ya ofrecen la funcionalidad
2. Buscar paquetes maduros del ecosistema
3. Verificar la salud de la librería (commits, issues, actividad)
4. Verificar compatibilidad con la configuración del proyecto

### Fase 6: Reporte integral
Generar un reporte detallado con:
- Resumen ejecutivo
- Problemas críticos que requieren atención inmediata
- Hallazgos archivo por archivo
- Plan de acción priorizado
- Estimaciones de esfuerzo
- Recomendaciones de librerías

## Niveles de prioridad de los problemas

- **Crítico** - Vulnerabilidades de seguridad, funcionalidad rota
- **Alta prioridad** - Cuellos de botella de rendimiento, código no mantenible
- **Prioridad media** - Calidad de código, desviaciones de buenas prácticas
- **Baja prioridad** - Estilo, mejoras menores
- **Quick wins** - Menos de 30 minutos para corregir

## Categorías de análisis

### Seguridad
- Secretos hardcodeados
- Riesgos de inyección SQL
- Vulnerabilidades XSS
- Validación de entradas faltante
- Datos sensibles expuestos

### Rendimiento
- Algoritmos ineficientes
- Operaciones bloqueantes
- Memory leaks
- Oportunidades de caching faltantes
- Patrones de consultas N+1

### TypeScript/Seguridad de tipos
- Anotaciones de tipo faltantes
- Uso del tipo `any`
- Tipos personalizados que duplican tipos oficiales
- Paquetes @types faltantes

### Problemas de Async/Promise
- Palabras clave await faltantes
- Rechazos de promesas sin manejar
- Callback hell

### Código muerto
- Imports y exports sin usar
- Funciones, clases y métodos sin usar
- Variables y tipos sin usar
- Bloques de código inalcanzables
- Archivos sin usar (no importados desde ningún lado)
- Dependencias sin usar

**Herramientas:**
- JavaScript/TypeScript: `npx knip --reporter json`
- Python: `deadcode . --dry`

**Importante:** Siempre verificá los hallazgos de las herramientas antes de reportarlos. Revisá:
- Imports dinámicos (`import(variable)`)
- Patrones de framework (componentes React, decoradores)
- Re-exports para la API pública
- Puntos de entrada (scripts CLI, handlers serverless)

## Recursos

Consultá los documentos de referencia para las metodologías completas:

- `references/audit-methodology.md` - Proceso completo de auditoría de 6 fases con checklists detallados
- `references/dead-code-methodology.md` - Herramientas de detección de código muerto, verificación y flujos de limpieza

## Referencia rápida

### Antes de empezar
- [ ] Leer los archivos de configuración del proyecto
- [ ] Identificar el stack tecnológico y las librerías
- [ ] Ejecutar los linters existentes como línea base
- [ ] Crear la lista de seguimiento de archivos

### Durante la auditoría
- [ ] Marcar archivos como en progreso
- [ ] Analizar cada categoría de forma sistemática
- [ ] Anotar números de línea específicos
- [ ] Documentar ejemplos de antes/después
- [ ] Marcar archivos como completados

### Después de la auditoría
- [ ] Categorizar todos los hallazgos por prioridad
- [ ] Generar el reporte integral
- [ ] Guardar el reporte en la raíz del proyecto
- [ ] Proveer un resumen breve por consola
