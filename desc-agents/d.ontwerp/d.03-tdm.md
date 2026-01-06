---
DVS-Positie: Stream D (Ontwerp) - D.03
Status: Actief
Contactpersoon: Enterprise Architectuur
Herziening: 04-01-2026
---

# Agent Beschrijving: D.03 - Technisch Datamodelleur (tdm)

## 1. Doel en Functionaliteit

De **Technisch Datamodelleur (tdm)** agent is een gespecialiseerde ontwerp-agent die verantwoordelijk is voor het vertalen van een **logisch datamodel** naar een **technisch/fysiek datamodel** dat platform-specifiek en performance-geoptimaliseerd is.

Deze agent transformeert het platform-onafhankelijke logische model (3NF) uit fase D.02 naar een implementatie-klaar database design met concrete datatypes, indexen, constraints en optimalisaties voor het gekozen database platform.

### Kernfunctionaliteiten:
- **Platform-specifieke Vertaling**: Zet conceptuele datatypes om naar platform-specifieke implementaties (VARCHAR, INT, TIMESTAMP, etc.).
- **Performance Optimalisatie**: Definieert strategische indexen op basis van query patronen en performance requirements.
- **Constraint Implementatie**: Implementeert primary keys, foreign keys, unique constraints en check constraints.
- **Denormalisatie**: Past onderbouwde denormalisatie toe waar performance dit vereist.
- **Partitioning**: Definieert table partitioning strategie voor grote datasets.
- **DDL Generatie**: Genereert volledige DDL (Data Definition Language) scripts voor het target platform.

## 2. DVS-Stream Positionering

Deze agent opereert primair in **Fase D - Ontwerp**, als directe opvolger van de LDM-agent.

- **Input**: Ontvangt logisch datamodel van D.02 (ldm-agent), plus platform-specificatie en performance requirements.
- **Output**: Levert platform-specifieke DDL scripts die direct gebruikt kunnen worden voor database-implementatie in Fase E (Bouw).
- **Positie**: D.03 - tussen logisch ontwerp (D.02) en fysieke implementatie (E.*)

## 3. Input en Output

### Input
- **Logisch Datamodel (LDM)**: Genormaliseerde entiteiten, attributen, PK's en FK's in 3NF formaat.
- **Platform Specificatie**: Target database platform (PostgreSQL, SQL Server, Oracle, MongoDB, etc.).
- **Performance Requirements**: 
  - Verwachte data volumes
  - Query patronen en frequenties
  - SLA's voor response times
  - Concurrent users
- **Business Rules**: Constraints, validaties en business logic die technisch moeten worden geïmplementeerd.
- **Governance**: Naamgevingsconventies, security policies, backup/recovery requirements.

### Output
- **Technisch Datamodel (TDM)**: Platform-specifiek database design in DDL formaat.
- **DDL Scripts**: 
  - CREATE TABLE statements met platform-specifieke datatypes
  - CREATE INDEX statements voor performance
  - CREATE VIEW statements voor rapportage/security
  - ALTER TABLE statements voor foreign keys
  - CREATE SEQUENCE/IDENTITY voor primary keys
- **Index Strategie**: Documentatie van indexen met onderbouwing.
- **Denormalisatie Documentatie**: Afwijkingen van 3NF met performance trade-offs.
- **Partitioning Strategie**: Table partitioning design (indien van toepassing).
- **Performance Notes**: Verwachte impact van optimalisaties.
- **Aannames**: Expliciete lijst van gemaakte technische aannames (max. 3).

## 4. Voorbeeld Use Case

**Scenario**: Een e-commerce platform heeft een logisch datamodel voor "Order Management" met entiteiten `Order`, `OrderLine`, `Product`, en `Customer`. Het platform verwacht 100K orders per dag met peak loads van 1000 orders per minuut.

### 1. **Input voor de agent**:
   - Logisch datamodel (3NF) van de LDM-agent
   - Platform: PostgreSQL 15
   - Performance requirements: 
     - 95% van queries < 100ms response time
     - 1000 concurrent users
     - 50M orders per jaar
   - Query patronen:
     - Order lookup by OrderID (100K queries/day)
     - Customer order history (10K queries/day)
     - Product sales aggregation (1K queries/day)

### 2. **Activatie**:
```bash
python scripts/d.tdm-realisatie.py \
    -i output/ldm/order-management.ldm.md \
    -p PostgreSQL \
    --performance-profile high-volume-oltp \
    -o output/tdm/order-management.tdm.sql
```

### 3. **Output**:
```sql
-- Technical Data Model: Order Management
-- Platform: PostgreSQL 15
-- Generated: 2026-01-04
-- Agent: D.03 tdm

-- Table: customer
CREATE TABLE customer (
    customer_id         BIGSERIAL PRIMARY KEY,
    customer_guid       UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    email               VARCHAR(255) NOT NULL UNIQUE,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,
    registration_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login          TIMESTAMP,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for email lookup (frequent authentication queries)
CREATE INDEX idx_customer_email ON customer(email);

-- Index for active customer filtering
CREATE INDEX idx_customer_active ON customer(is_active) WHERE is_active = TRUE;

-- Table: product
CREATE TABLE product (
    product_id          BIGSERIAL PRIMARY KEY,
    product_code        VARCHAR(50) NOT NULL UNIQUE,
    product_name        VARCHAR(200) NOT NULL,
    description         TEXT,
    unit_price          DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity      INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_available        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for product lookup by code
CREATE INDEX idx_product_code ON product(product_code);

-- Index for available products filtering
CREATE INDEX idx_product_available ON product(is_available) WHERE is_available = TRUE;

-- Table: order (partitioned by order_date for high volume)
CREATE TABLE "order" (
    order_id            BIGSERIAL,
    order_guid          UUID NOT NULL DEFAULT gen_random_uuid(),
    customer_id         BIGINT NOT NULL,
    order_date          DATE NOT NULL,
    order_status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    total_amount        DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address    JSONB NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (order_date);

-- Partitions for 2026 (quarterly)
CREATE TABLE order_2026_q1 PARTITION OF "order"
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

CREATE TABLE order_2026_q2 PARTITION OF "order"
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');

CREATE TABLE order_2026_q3 PARTITION OF "order"
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');

CREATE TABLE order_2026_q4 PARTITION OF "order"
    FOR VALUES FROM ('2026-10-01') TO ('2027-01-01');

-- Index for customer order lookup (critical query pattern)
CREATE INDEX idx_order_customer ON "order"(customer_id, order_date DESC);

-- Index for order status filtering
CREATE INDEX idx_order_status ON "order"(order_status);

-- Table: order_line
CREATE TABLE order_line (
    order_line_id       BIGSERIAL PRIMARY KEY,
    order_id            BIGINT NOT NULL,
    product_id          BIGINT NOT NULL,
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    unit_price          DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    line_total          DECIMAL(12,2) NOT NULL CHECK (line_total >= 0),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for order line lookup (JOIN performance)
CREATE INDEX idx_order_line_order ON order_line(order_id);

-- Index for product sales analysis
CREATE INDEX idx_order_line_product ON order_line(product_id);

-- Foreign Key Constraints
ALTER TABLE "order" 
    ADD CONSTRAINT fk_order_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES customer(customer_id) 
    ON DELETE RESTRICT;

ALTER TABLE order_line 
    ADD CONSTRAINT fk_order_line_order 
    FOREIGN KEY (order_id) 
    REFERENCES "order"(order_id) 
    ON DELETE CASCADE;

ALTER TABLE order_line 
    ADD CONSTRAINT fk_order_line_product 
    FOREIGN KEY (product_id) 
    REFERENCES product(product_id) 
    ON DELETE RESTRICT;

-- Materialized View: Product Sales Summary (for reporting)
CREATE MATERIALIZED VIEW mv_product_sales_summary AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    COUNT(DISTINCT ol.order_id) AS order_count,
    SUM(ol.quantity) AS total_quantity_sold,
    SUM(ol.line_total) AS total_revenue,
    AVG(ol.unit_price) AS avg_unit_price
FROM product p
LEFT JOIN order_line ol ON p.product_id = ol.product_id
GROUP BY p.product_id, p.product_code, p.product_name;

-- Index on materialized view for fast reporting
CREATE INDEX idx_mv_product_sales_revenue 
    ON mv_product_sales_summary(total_revenue DESC);

-- View: Customer Order History (security & simplification)
CREATE VIEW v_customer_order_history AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM customer c
INNER JOIN "order" o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;
```

**Documentatie Output**:
```markdown
# Technical Data Model: Order Management

## Platform
PostgreSQL 15

## Design Decisions

### 1. Partitioning Strategy
- **Table**: `order`
- **Method**: Range partitioning by `order_date`
- **Rationale**: With 100K orders/day (36.5M/year), partitioning improves query performance and maintenance operations (backup, archival)
- **Partition Size**: Quarterly partitions (~9M records per partition)

### 2. Indexing Strategy
**High-priority indexes**:
- `idx_order_customer`: Composite index for customer order history (10K queries/day)
- `idx_customer_email`: Single-column index for authentication (100K queries/day)
- `idx_order_line_order`: Foreign key index for JOIN performance

**Filtered indexes**:
- `idx_customer_active`: Only indexes active customers (reduces index size)
- `idx_product_available`: Only indexes available products

### 3. Denormalization
**Materialized View**: `mv_product_sales_summary`
- **Rationale**: Product sales aggregation query (1K/day) is computation-heavy
- **Trade-off**: Slightly stale data (refresh hourly) vs. real-time query load
- **Refresh Strategy**: Scheduled REFRESH MATERIALIZED VIEW every hour

### 4. Data Types
- **IDs**: BIGSERIAL for primary keys (supports > 9 quintillion records)
- **GUIDs**: UUID for external references (customer_guid, order_guid)
- **Money**: DECIMAL(10,2) for prices, DECIMAL(12,2) for totals (avoids floating-point errors)
- **Addresses**: JSONB for flexible address structure (no schema changes for international addresses)

### 5. Constraints
- **Check Constraints**: Prevent negative prices and quantities
- **Foreign Keys**: 
  - CASCADE on order_line → order (order deletion removes lines)
  - RESTRICT on order → customer (prevent customer deletion with orders)

## Performance Expectations
- Order lookup by ID: < 5ms (indexed primary key)
- Customer order history: < 50ms (composite index)
- Product sales summary: < 10ms (materialized view)

## Assumptions
1. 🔹 Orders older than 2 years will be archived to separate tables
2. 🔹 Customer addresses are international (hence JSONB for flexibility)
3. 🔹 Product sales summary can tolerate 1-hour staleness

## Limitations
- Materialized view refresh requires write lock (refresh during low-traffic periods)
- Partition management requires quarterly DDL operations
- JSONB indexes not included (requires application-specific query patterns)
```

## 5. Workflow

### Stap 1: Input Validatie
- Controleer dat logisch datamodel (LDM) aanwezig is
- Verifieer platform-specificatie
- Lees charter: `C:\gitrepo\standards\charters.agents\d.ontwerp\std.agent.charter.d.tdm.md`

### Stap 2: Datatype Mapping
- Vertaal conceptuele datatypes naar platform-specifieke implementaties
- Bepaal lengte/precisie voor VARCHAR, DECIMAL, etc.
- Kies primary key strategie (SERIAL, IDENTITY, UUID, natural key)

### Stap 3: Constraint Definitie
- Definieer primary key constraints
- Implementeer foreign key constraints met cascade rules
- Voeg check constraints toe voor business rules
- Definieer unique constraints voor business keys

### Stap 4: Index Strategie
- Analyseer query patronen uit performance requirements
- Definieer indexen voor:
  - Foreign keys (JOIN performance)
  - WHERE clause kolommen (filtering)
  - ORDER BY kolommen (sorting)
  - Unique business keys
- Overweeg filtered indexes voor selectieve data

### Stap 5: Performance Optimalisatie
- Evalueer denormalisatie voor:
  - Veelgebruikte aggregaties → Materialized views
  - N+1 query problemen → Embedded data
  - Read-heavy workloads → Redundant kolommen
- Overweeg partitioning voor grote tabellen (> 10M records)
- Definieer views voor rapportage en security

### Stap 6: Platform-specifieke Features
- **PostgreSQL**: JSONB, ARRAY, GIN indexes, table inheritance
- **SQL Server**: Computed columns, filtered indexes, columnstore
- **Oracle**: Partitioning, materialized views, function-based indexes
- **MongoDB**: Document design, embedded vs. referenced, compound indexes

### Stap 7: DDL Generatie
- Genereer CREATE TABLE statements
- Genereer CREATE INDEX statements
- Genereer CREATE VIEW/MATERIALIZED VIEW statements
- Genereer ALTER TABLE voor foreign keys
- Voeg commentaar toe voor context

### Stap 8: Documentatie
- Documenteer design decisions met rationale
- Beschrijf performance trade-offs
- Noteer afwijkingen van logisch model
- Documenteer maximaal 3 aannames

## 6. Relatie met Andere Agents

### Upstream Agents (Levert Input)
- **D.02 ldm (Logisch Datamodelleur)**: Levert logisch datamodel in 3NF
- **C.01 feature-analist**: Levert performance requirements en query patronen
- **B.01 cdm-architect**: Levert conceptueel model en business rules

### Downstream Agents (Ontvangt Output)
- **E.* (Bouw agents)**: Gebruiken DDL scripts voor database-implementatie
- **F.* (Validatie agents)**: Valideren database design tegen performance requirements

### Parallel Agents
- **D.01 service-architect**: Definieert services die database benaderen (query patterns)
- **D.02 ldm**: Directe voorganger (vertaalt LDM → TDM)

## 7. Beperkingen en Afhankelijkheden

### Wat deze agent NIET doet
- ❌ Database provisioning of deployment automation
- ❌ Data migratie scripts (INSERT/UPDATE statements)
- ❌ Stored procedures of triggers (business logic in database)
- ❌ Database security configuratie (users, roles, permissions)
- ❌ Backup/recovery procedures
- ❌ Performance tuning na implementatie
- ❌ Query optimalisatie voor applicatie-code

### Wat deze agent WEL doet
- ✅ Platform-specifieke DDL generatie
- ✅ Index strategie definitie
- ✅ Constraint implementatie
- ✅ Onderbouwde denormalisatie
- ✅ Partitioning strategie
- ✅ View definitie voor rapportage
- ✅ Performance trade-off documentatie

### Afhankelijkheden
- De kwaliteit van de output is afhankelijk van:
  - Volledigheid van het logische datamodel
  - Nauwkeurigheid van performance requirements
  - Beschikbaarheid van query patronen
- De agent is een hulpmiddel voor database-ontwerp, geen vervanging voor een data-architect
- De agent baseert zich op de regels en principes uit de charter: `std.agent.charter.d.tdm.md`

## 8. Kwaliteitscriteria

Deze agent waarborgt:
- **Platform Compliance**: DDL is syntactisch correct voor target platform
- **Performance Optimized**: Indexen zijn afgestemd op query patronen
- **Constraint Complete**: Alle PK, FK, unique en check constraints zijn gedefinieerd
- **Traceability**: Alle design decisions zijn herleidbaar naar logisch model of performance requirements
- **Documentation**: Denormalisatie en optimalisaties zijn gedocumenteerd met rationale
- **Maintainability**: Partitioning en archival strategie voor grote datasets
- **Security Ready**: Views voor kolom-niveau security waar relevant
- **Charter Compliance**: Werkt volgens principes in charter

**Output formaat**:
- **DDL Scripts**: SQL bestanden per platform met complete schema definitie
- **Documentatie**: Markdown bestand met design decisions en trade-offs
- **Aannames**: Maximaal 3 expliciete aannames

## 9. Gebruik

### Activatie via Command Line
```bash
# Basis gebruik (cross-platform Python)
python scripts/d.tdm-realisatie.py \
    -i output/ldm/my-model.ldm.md \
    -p PostgreSQL \
    -o output/tdm/my-model.tdm.sql

# Met performance profiel
python scripts/d.tdm-realisatie.py \
    -i output/ldm/order-management.ldm.md \
    -p SQLServer \
    --performance-profile high-volume-oltp \
    -o output/tdm/order-management.tdm.sql

# Met partitioning
python scripts/d.tdm-realisatie.py \
    -i output/ldm/analytics.ldm.md \
    -p PostgreSQL \
    --enable-partitioning \
    --partition-strategy range-by-date \
    -o output/tdm/analytics.tdm.sql

# MongoDB document design
python scripts/d.tdm-realisatie.py \
    -i output/ldm/product-catalog.ldm.md \
    -p MongoDB \
    --document-design embedded \
    -o output/tdm/product-catalog.mongodb.js
```

### Activatie via GitHub Copilot
```
@workspace /d.tdm Maak een technisch datamodel voor PostgreSQL op basis van output/ldm/order-management.ldm.md met high-volume OLTP optimalisatie
```

### Parameters
- **InputFiles**: Pad naar logisch datamodel (LDM) bestand
- **Platform**: Target database (PostgreSQL, SQLServer, Oracle, MySQL, MongoDB)
- **OutputFile**: Pad voor output DDL/script bestand
- **PerformanceProfile**: Optioneel (low-volume, medium-volume, high-volume-oltp, high-volume-olap)
- **EnablePartitioning**: Switch voor table partitioning
- **PartitionStrategy**: Partitioning methode (range-by-date, hash, list)
- **DocumentDesign**: Voor NoSQL (embedded, referenced, hybrid)

## 10. Voorbeeld Output Artefacten

### Bestand: `order-management.tdm.sql`
Volledige DDL met CREATE TABLE, INDEX, VIEW statements

### Bestand: `order-management.tdm-docs.md`
Documentatie met:
- Design decisions
- Index strategie
- Denormalisatie trade-offs
- Performance expectations
- Aannames (max. 3)
- Limitations

---

**Charter**: https://github.com/hans-blok/standard/blob/main/charters.agents/d.ontwerp/std.agent.charter.d.tdm.md  
**Versie**: 1.0  
**Laatste update**: 04-01-2026
