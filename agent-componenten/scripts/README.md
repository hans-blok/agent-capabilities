# Agent-Capabilities Scripts

Python-gebaseerde runner scripts voor cross-platform compatibiliteit (Windows, Linux, macOS).

## 📋 Vereisten

- Python 3.8 of hoger
- pip (Python package manager)

## 🚀 Installatie

```bash
# Installeer vereiste packages
pip install -r requirements.txt

# Maak scripts executable (Unix/Linux/macOS)
chmod +x scripts/*.py
```

## 📚 Beschikbare Scripts

### Core Builder Scripts

#### 0.make-agent.py
Hoofdscript om een nieuwe agent te creëren op basis van een charter.

```bash
python scripts/0.make-agent.py --agent-name "founding-hypothesis-owner"
```

#### 0.prompt-builder.py
Genereert agent prompt bestanden op basis van charter.

```bash
python scripts/0.prompt-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json
```

#### 0.runner-builder.py
Genereert agent runner scripts.

```bash
python scripts/0.runner-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json
```

#### 0.orchestration-builder.py
Genereert orchestration configuratie (YAML).

```bash
python scripts/0.orchestration-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json
```

### Ontwerp Agents (Stream D)

#### d.tdm-realisatie.py
Technisch Datamodel (TDM) - vertaalt logisch model naar platform-specifiek database design.

```bash
# Basis gebruik
python scripts/d.tdm-realisatie.py \
    -i output/ldm/order-management.ldm.md \
    -p PostgreSQL

# Met performance optimalisatie
python scripts/d.tdm-realisatie.py \
    -i output/ldm/analytics.ldm.md \
    -p PostgreSQL \
    --performance-profile high-volume-olap \
    --include-materialized-views

# SQL Server met partitioning
python scripts/d.tdm-realisatie.py \
    -i order-management.ldm.md \
    -p SQLServer \
    --performance-profile high-volume-oltp \
    --enable-partitioning \
    -o output/tdm/order-management.sql

# MongoDB document design
python scripts/d.tdm-realisatie.py \
    -i catalog.ldm.md \
    -p MongoDB \
    --document-design embedded
```

**Ondersteunde platforms:**
- PostgreSQL (met JSONB, partitioning, materialized views)
- SQLServer (met filtered indexes, computed columns)
- Oracle (met advanced partitioning)
- MySQL (met JSON support)
- MongoDB (NoSQL document design)

**Performance profielen:**
- `low-volume`: < 100K records
- `medium-volume`: 100K - 10M records (default)
- `high-volume-oltp`: > 10M records, write-heavy
- `high-volume-olap`: > 10M records, read-heavy

## 🔧 Algemene Opties

Alle scripts ondersteunen de volgende algemene opties:

- `-h, --help`: Toon help informatie
- `-v, --verbose`: Uitgebreide logging
- `-i, --input-files`: Input bestanden (meerdere mogelijk)
- `-o, --output-file`: Output bestand pad

## 🐍 Waarom Python?

Alle scripts zijn in Python geschreven voor optimale compatibiliteit:

1. **Cross-platform**: Werkt op Windows, Linux en macOS
2. **Modernere syntax**: Gebruik van type hints en dataclasses
3. **Betere error handling**: Expliciete exception handling
4. **Package management**: Via pip/requirements.txt
5. **Toekomstbestendig**: Voorbereid op container/cloud deployment
6. **Cloud-ready**: Ideaal voor containers en Linux-omgevingen

## 📝 Development

### Code Style
Scripts volgen PEP 8 Python style guide:
- Type hints voor functie parameters en return types
- Docstrings voor alle classes en functies
- Maximum line length: 100 characters
- 4 spaces indentation

### Testing
```bash
# Run individual script with test data
python scripts/d.tdm-realisatie.py -i test/data/sample.ldm.md -p PostgreSQL

# Check syntax
python -m py_compile scripts/*.py
```

### Logging
Alle scripts gebruiken een consistent logging formaat:
- `[INFO]` - Algemene informatie (cyan)
- `[SUCCESS]` - Succesvolle operaties (green)  
- `[WARNING]` - Waarschuwingen (yellow)
- `[ERROR]` - Fouten (red)

## ✅ Alleen Python

Alle runner scripts zijn nu uitsluitend in Python:
- Geen PowerShell dependencies meer
- Volledige Linux/Unix support
- Eenvoudigere CI/CD pipelines
- Container-ready zonder extra configuratie

## 📦 Dependencies

Zie `requirements.txt` voor volledige lijst. Belangrijkste dependencies:
- `pyyaml`: YAML configuratie parsing
- `argparse`: Command-line argument parsing (stdlib)
- `pathlib`: Path manipulation (stdlib)
- `typing`: Type hints (stdlib)

## 🆘 Troubleshooting

### Python niet gevonden
```bash
# Windows
where python

# Linux/macOS
which python3
```

### Permission denied (Linux/macOS)
```bash
chmod +x scripts/*.py
```

### Module niet gevonden
```bash
pip install -r requirements.txt
```

### Encoding errors
Scripts gebruiken UTF-8 encoding. Zorg dat je terminal UTF-8 ondersteunt:
```bash
# Linux/macOS
export LANG=en_US.UTF-8

# Windows PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

## 📄 Licentie

Zie LICENSE bestand in repository root.
