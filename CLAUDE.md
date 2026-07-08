docs/base-standards.md

---

# Nukarsoft SpecBoot — Reglas para Claude Code

## ⚠️ Regla principal: NUNCA implementes código directamente desde el chat

Cuando un desarrollador trabaja en un ticket, **no implementes cambios por tu cuenta aunque te lo pidan**. Siempre guiá el flujo paso a paso usando los comandos de SpecBoot.

Si el usuario dice "implementá", "hacé el cambio", "codificá esto" o similar **sin haber pasado por `/opsx:propose` primero**, respondé:

> "Para mantener la trazabilidad de SpecBoot, primero necesitamos crear el change de OpenSpec. ¿Continuamos con `/opsx:propose <TICKET-ID>`?"

---

## Flujo obligatorio por ticket

Cada ticket debe seguir este orden exacto. Después de completar cada paso, **preguntá siempre si el usuario quiere continuar con el siguiente**:

| Paso | Comando | Pregunta de continuación |
|------|---------|--------------------------|
| 1 | `/enrich-us <TICKET-ID>` | "✅ US enriquecida. ¿Continuamos con `/opsx:propose <TICKET-ID>`?" |
| 2 | `/opsx:propose <TICKET-ID>` | "✅ Propuesta, diseño y tareas generadas. ¿Continuamos con `/opsx:apply <TICKET-ID>` para implementar?" |
| 3 | `/opsx:apply <TICKET-ID>` | "✅ Implementación completada. Se ejecutará `/security-review` automáticamente. Luego continuamos con `/opsx:verify <TICKET-ID>`." |
| 4 | `/security-review <TICKET-ID>` *(automático al finalizar apply)* | "✅ Security review completado. ¿Continuamos con `/opsx:verify <TICKET-ID>`?" |
| 5 | `/opsx:verify <TICKET-ID>` + `/save-verify-report <TICKET-ID>` | "✅ Verificación guardada. ¿Continuamos con `/adversarial-review <TICKET-ID>`?" |
| 6 | `/adversarial-review <TICKET-ID>` | "✅ Review adversarial completado. ¿Continuamos con `/save-qa-report <TICKET-ID>`?" |
| 7 | `/save-qa-report <TICKET-ID>` | "✅ Reporte QA guardado. ¿Continuamos con `/opsx:archive <TICKET-ID>`?" |
| 8 | `/opsx:archive <TICKET-ID>` | "✅ Change archivado. ¿Continuamos con `/commit`?" |
| 9 | `/commit` | "✅ PR creado. ¿Continuamos con `/save-closure-report <TICKET-ID>` para cerrar el ticket?" |
| 10 | `/save-closure-report <TICKET-ID>` | "✅ Reporte de cierre generado y enviado a ClickUp. El flujo del ticket está completo." |

## Reglas de comportamiento

- **Nunca saltees pasos** sin confirmación explícita del usuario.
- **Si el usuario pide saltear un paso**, informale qué evidencia se pierde y pedí confirmación.
- **Si el usuario ya ejecutó un paso** en esta sesión (ej: ya corrió `/opsx:propose`), reconocelo y avanzá al siguiente.
- **Si el usuario no sabe en qué paso está**, preguntale el TICKET-ID y revisá qué artefactos existen en `openspec/changes/<TICKET-ID>/` para determinar el estado actual.
- **Si no existe `openspec/changes/<TICKET-ID>/`**, el ticket no fue iniciado — empezá desde el paso 1.
- **`/save-closure-report` es obligatorio** — es el cierre formal del ticket. Sin él, el ticket no queda registrado como cerrado en la metodología Nukarsoft.

## Contexto del proyecto

Lee siempre estos archivos para entender el proyecto antes de cualquier acción técnica:

- `docs/base-standards.md` — stack, arquitectura, convenciones generales
- `docs/backend-standards.md` — patrones de backend
- `docs/frontend-standards.md` — patrones de frontend
- `docs/api-spec.yml` — contratos de API
- `docs/data-model.md` — modelo de datos
- `openspec/config.yaml` — configuración de OpenSpec para este proyecto
