# MD-to-DSL Converter Agent

**Agent ID**: `std.u.md-to-dsl`  
**Fase**: U (Utility)  
**Versie**: 1.0.0

## Doel

Converteert Markdown architectuurbeschrijvingen naar syntactisch correcte Structurizr DSL workspace-bestanden.

## Primaire Verantwoordelijkheid

**Technische conversie** van Markdown/Mermaid C4 diagrammen naar renderbare `workspace.dsl` bestanden.

## Input

- Markdown architectuurbeschrijvingen
- C4 diagrammen in Mermaid syntax
- Bestaande DSL-fragmenten (voor validatie/optimalisatie)

## Output

- `workspace.dsl` bestand met:
  - Syntactisch correcte Structurizr DSL
  - Hierarchical identifier compliance
  - System context, container en component views
  - Consistente styling per element type
  - Metadata (timestamp, bron, elementtelling)

## Kernprincipes

1. **Syntactische correctheid** — Output moet valideren zonder errors
2. **Hierarchical compliance** — Volledige paden bij `!identifiers hierarchical`
3. **Complete mapping** — Alle Markdown elementen worden DSL elementen
4. **No hallucination** — Geen verzonnen componenten of relaties

## Kwaliteitspoorten

- ☑ Syntax valideert in Structurizr
- ☑ Alle relationships gebruiken volledig pad (bij hierarchical mode)
- ☑ Alle elementen uit Markdown zijn overgenomen
- ☑ Views dekken alle containers en components
- ☑ Autolayout gedefinieerd per view

## Anti-Patterns

❌ Identifiers zonder volledig pad bij hierarchical mode  
❌ Views zonder autolayout directive  
❌ External systems zonder "External" tag  
❌ Components buiten container context  
❌ Relationships zonder beschrijving/technologie

## Expertise

- Structurizr DSL syntax (hierarchical identifiers)
- C4 model (Context, Container, Component, Code)
- Mermaid diagram parsing
- Visual styling voor architectuurdiagrammen

## Scope

**WEL**: Technische conversie Markdown → DSL  
**NIET**: Architectuurbesluiten, domeinlogica, elementen verzinnen

## Charter

Utility agents hebben geen formeel charter. Deze agent opereert volgens de werkwijze gedefinieerd in `.github/agents/std.u.md-to-dsl.agent.md`.

---

*Laatst bijgewerkt: 2025-12-14*
