# Migratie Gids: PowerShell naar Python

Deze gids helpt bij de overgang van PowerShell naar Python scripts voor agent-capabilities.

## 📊 Waarom Python?

### Voordelen van Python
✅ **Cross-platform**: Werkt op Windows, Linux en macOS zonder aanpassingen  
✅ **Cloud-ready**: Ideaal voor containers, Kubernetes, cloud deployments  
✅ **Moderne ecosystem**: Rijke set aan libraries voor data processing, ML, APIs  
✅ **Toekomstbestendig**: Linux-omgevingen worden steeds meer de standaard  
✅ **Developer-friendly**: Eenvoudigere syntax, betere IDE support  
✅ **Package management**: pip/requirements.txt voor dependency management  

### PowerShell Scripts verwijderd
✅ Alle PowerShell scripts (`.ps1`) zijn verwijderd  
✅ Alleen Python versies worden ondersteund  
✅ Volledige focus op cross-platform compatibiliteit  

## 🔄 Command Equivalenties

### D.TDM Realisatie

**PowerShell (oud):**
```powershell
.\scripts\d.tdm-realisatie.ps1 `
    -InputFiles "output\ldm\order-management.ldm.md" `
    -Platform "PostgreSQL" `
    -PerformanceProfile "high-volume-oltp" `
    -OutputFile "output\tdm\order-management.sql"
```

**Python (nieuw):**
```bash
python scripts/d.tdm-realisatie.py \
    -i output/ldm/order-management.ldm.md \
    -p PostgreSQL \
    --performance-profile high-volume-oltp \
    -o output/tdm/order-management.sql
```

**Universele wrapper (automatische detectie):**
```bash
# Linux/macOS
./scripts/run-agent.sh d.tdm-realisatie \
    -i output/ldm/order-management.ldm.md \
    -p PostgreSQL

# Windows
scripts\run-agent.bat d.tdm-realisatie ^
    -i output\ldm\order-management.ldm.md ^
    -p PostgreSQL
```

### 0.Make-Agent

**PowerShell (oud):**
```powershell
.\scripts\0.make-agent.ps1 -AgentName "test-agent"
```

**Python (nieuw):**
```bash
python scripts/0.make-agent.py --agent-name "test-agent"
```

**Universele wrapper:**
```bash
./scripts/run-agent.sh 0.make-agent --agent-name "test-agent"
```

## 🔧 Parameter Mapping

| PowerShell | Python | Beschrijving |
|------------|--------|--------------|
| `-InputFiles` | `-i, --input-files` | Input bestanden |
| `-OutputFile` | `-o, --output-file` | Output bestand |
| `-Platform` | `-p, --platform` | Database platform |
| `-PerformanceProfile` | `--performance-profile` | Performance profiel |
| `-EnablePartitioning` | `--enable-partitioning` | Partitioning switch |
| `-PartitionStrategy` | `--partition-strategy` | Partitioning strategie |
| `-NamingConvention` | `--naming-convention` | Naamgeving conventie |
| `-ModelName` | `-n, --model-name` | Model naam |
| `-AgentName` | `--agent-name` | Agent naam |
| `-Verbose` | `-v, --verbose` | Uitgebreide logging |

### Algemene verschillen:
- **PowerShell**: PascalCase parameters (bijv. `-InputFiles`)
- **Python**: kebab-case met dubbele dash (bijv. `--input-files`)
- **Python**: Korte opties met enkele dash (bijv. `-i`)

## 📦 Installatie & Setup

### 1. Installeer Python

**Windows:**
```powershell
# Via winget
winget install Python.Python.3.12

# Verifieer
python --version  # Moet Python 3.8+ tonen
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip
python3 --version
```

**macOS:**
```bash
# Via Homebrew
brew install python3
python3 --version
```

### 2. Installeer Dependencies

```bash
# In de repository root
pip install -r requirements.txt

# Of met Python 3 expliciet
python3 -m pip install -r requirements.txt
```

### 3. Maak Scripts Executable (Unix/Linux/macOS)

```bash
chmod +x scripts/*.py
chmod +x scripts/run-agent.sh
```

### 4. Test de Installatie

```bash
# Test een script
python scripts/d.tdm-realisatie.py --help

# Of via wrapper
./scripts/run-agent.sh d.tdm-realisatie --help
```

## 🚀 Gebruik in CI/CD

### GitHub Actions

**Oude workflow (PowerShell):**
```yaml
- name: Run TDM Agent
  shell: pwsh
  run: |
    .\scripts\d.tdm-realisatie.ps1 `
      -InputFiles "input.ldm.md" `
      -Platform "PostgreSQL"
```

**Nieuwe workflow (Python):**
```yaml
- name: Setup Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.11'

- name: Install dependencies
  run: pip install -r requirements.txt

- name: Run TDM Agent
  run: |
    python scripts/d.tdm-realisatie.py \
      -i input.ldm.md \
      -p PostgreSQL
```

### Docker Container

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy scripts
COPY scripts/ ./scripts/

# Run agent
ENTRYPOINT ["python", "scripts/d.tdm-realisatie.py"]
```

**Gebruik:**
```bash
docker build -t agent-tdm .
docker run agent-tdm -i /data/input.ldm.md -p PostgreSQL
```

## 🔍 Troubleshooting

### Python niet gevonden

**Probleem:**
```
'python' is not recognized as an internal or external command
```

**Oplossing:**
```bash
# Windows: Check Python installatie
where python
where python3

# Gebruik volledige pad indien nodig
C:\Users\YourName\AppData\Local\Programs\Python\Python311\python.exe scripts/d.tdm-realisatie.py
```

### Module niet gevonden

**Probleem:**
```
ModuleNotFoundError: No module named 'yaml'
```

**Oplossing:**
```bash
pip install -r requirements.txt

# Of specifiek
pip install pyyaml
```

### Permission denied (Linux/macOS)

**Probleem:**
```
bash: ./scripts/d.tdm-realisatie.py: Permission denied
```

**Oplossing:**
```bash
chmod +x scripts/*.py
```

### Encoding errors

**Probleem:**
```
UnicodeDecodeError: 'charmap' codec can't decode byte
```

**Oplossing:**
```bash
# Windows: Zet console naar UTF-8
chcp 65001

# PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Linux/macOS: Zet locale
export LANG=en_US.UTF-8
```

## 📝 Ontwikkeling

### Voor ontwikkelaars die scripts aanpassen

**Python code style:**
```bash
# Install development tools
pip install pylint black mypy

# Format code
black scripts/*.py

# Lint
pylint scripts/*.py

# Type check
mypy scripts/*.py
```

**Testing:**
```bash
# Syntax check
python -m py_compile scripts/*.py

# Run script met test data
python scripts/d.tdm-realisatie.py \
    -i test/fixtures/sample.ldm.md \
    -p PostgreSQL \
    -o /tmp/test-output.sql
```

## 🎯 Best Practices

### 1. Gebruik Virtual Environments

```bash
# Maak virtual environment
python -m venv .venv

# Activeer (Linux/macOS)
source .venv/bin/activate

# Activeer (Windows)
.venv\Scripts\activate

# Installeer dependencies
pip install -r requirements.txt
```

### 2. Gebruik Universal Wrapper in Scripts

In plaats van directe Python calls:
```bash
# ❌ Niet doen
python scripts/d.tdm-realisatie.py -i input.md

# ✅ Wel doen (werkt overal)
./scripts/run-agent.sh d.tdm-realisatie -i input.md
```

### 3. Pin Python Versie

In `requirements.txt`:
```
# Python version requirement
python_requires>=3.8
```

### 4. Test op Meerdere Platforms

```bash
# Test matrix
# - Windows + Python 3.8, 3.9, 3.10, 3.11
# - Linux + Python 3.8, 3.9, 3.10, 3.11
# - macOS + Python 3.11
```

## 📚 Meer Informatie

- [scripts/README.md](README.md) - Gedetailleerde script documentatie
- [Python Packaging Guide](https://packaging.python.org/)
- [Cross-platform Python](https://docs.python.org/3/library/os.html)

## 🆘 Support

Voor vragen over de migratie:
1. Check deze gids eerst
2. Bekijk [scripts/README.md](README.md)
3. Test met universal wrapper (`run-agent.sh`/`run-agent.bat`)
4. Open een issue in de repository

---

**Status**: Alle core scripts zijn beschikbaar in Python  
**Laatste update**: 04-01-2026  
**Maintainer**: Agent-Capabilities Team
