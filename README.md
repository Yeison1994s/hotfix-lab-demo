# Laboratorio SCM – Integración de Hotfix (Azure DevOps)

Este laboratorio permite practicar el proceso completo de integración de ramas `hotfix`
siguiendo la estrategia DevSecOps (hotfix → master → QA → develop).

## Objetivo
Simular un bug en producción y realizar el proceso correcto de integración.

## Flujo del ejercicio

| Etapa | Acción | Estrategia |
|-------|---------|------------|
| 1 | Crear rama `hotfix/fix-typo` desde `master` | — |
| 2 | Corregir bug (“Heloo” → “Hello”) | — |
| 3 | Crear PR a `master` | Squash Commit |
| 4 | Crear rama `task-resolution` desde `QA` | — |
| 5 | Rebase con `master` y PR a `QA` | Rebase and Fast-forward |
| 6 | Crear rama `task-resolution` desde `develop` | — |
| 7 | Rebase con `QA` y PR a `develop` | Rebase and Fast-forward |
| 8 | Validar pipelines y eliminar ramas temporales | — |

---

## Roles
- **SCM:** ejecuta el flujo completo.  
- **Líder técnico:** aprueba y elimina ramas `hotfix`.

## Comandos Git usados
```bash
git rebase origin/master
git pull --no-rebase
git push
