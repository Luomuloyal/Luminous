# Knowledge Data Platform Plan

Last updated: 2026-05-25

## 1. Why this exists

Luminous is moving from a small medicine lookup app toward a personal health management copilot. The data layer therefore needs to move from bundled sample assets and a legacy MySQL medicine table to a server-side knowledge platform.

This plan is the source of truth for the new medicine/health knowledge direction. It is intentionally docs-first: do not import the large datasets into the repo, do not commit generated database dumps, and do not start the backend rewrite before the Flutter Phase 0 base is stable.

## 2. New data sources

### 2.1 Chinese product and instruction dataset

Source: `D:\DrugDataBase\FullDrugDetail.xlsx`

Observed on 2026-05-25:

- Workbook: 1 sheet named `总的`.
- Size: about 80.4 MiB.
- Rows: 204,845 including header; 204,844 data rows.
- Columns: 29.
- Header renamed to English snake_case (2026-05-25) for safe use in PostgreSQL/Prisma.

Column mapping:

| # | English (header) | Original Chinese | Suggested PG type | Notes |
|---|---|---|---|---|
| 1 | `product_name` | 产品名称 | `text` | Search primary key |
| 2 | `image_url` | 药品图片 | `text` | External URL, may be empty |
| 3 | `price` | 价格 | `text` | Free-text price |
| 4 | `package_spec` | 包装规格 | `text` | e.g. "10片/盒" |
| 5 | `approval_number` | 批准文号 | `text` | National drug approval ID |
| 6 | `manufacturer` | 生产厂家 | `text` | Manufacturer name |
| 7 | `drug_type` | 药品类型 | `text` | Rx/OTC etc. |
| 8 | `main_category` | 主分类 | `text` | Top-level category |
| 9 | `subcategory` | 子分类 | `text` | Sub-category |
| 10 | `detail_url` | 详情链接 | `text` | Source page URL |
| 11 | `brand_name` | 商品名/商标 | `text` | Brand/trademark |
| 12 | `ingredients` | 成份 | `text` | Active + excipients |
| 13 | `properties` | 性状 | `text` | Appearance/character |
| 14 | `indications` | 功能主治/适应症 | `text` | Indications |
| 15 | `dosage` | 用法用量 | `text` | Dosage instructions |
| 16 | `adverse_reactions` | 不良反应 | `text` | Adverse reactions |
| 17 | `contraindications` | 禁忌 | `text` | Contraindications |
| 18 | `precautions` | 注意事项 | `text` | Precautions |
| 19 | `pediatric_use` | 儿童用药 | `text` | Pediatric usage |
| 20 | `geriatric_use` | 老年患者用药 | `text` | Geriatric usage |
| 21 | `pregnancy_lactation` | 孕妇及哺乳期妇女用药 | `text` | Pregnancy & lactation |
| 22 | `pharmacology_toxicology` | 药理毒理 | `text` | Pharmacology/toxicology |
| 23 | `drug_interactions` | 药物相互作用 | `text` | Drug interactions |
| 24 | `pharmacokinetics` | 药代动力学 | `text` | Pharmacokinetics |
| 25 | `overdose` | 药物过量 | `text` | Overdose management |
| 26 | `storage` | 贮藏 | `text` | Storage conditions |
| 27 | `validity_period` | 有效期 | `text` | Validity period |
| 28 | `barcode` | 条形码 | `text` | Product barcode |
| 29 | `national_drug_code` | 药品本位码 | `text` | National drug code |

All columns are free-text Chinese content. Use `text` / `varchar` with UTF-8 encoding, never `enum`. Apply `pg_trgm` GIN indexes to `product_name`, `brand_name`, `manufacturer`, `approval_number`, and `national_drug_code` for fuzzy search.

Recommended role:

- Primary user-facing Chinese medicine knowledge source.
- Source for medicine search, detail, package/specification lookup, label-style instruction sections, reminder setup context, and deterministic Markdown rendering.
- Replaces the old full JSON/Excel asset approach. The app must not bundle this xlsx.

### 2.2 DrugBank dataset

Source directory: `D:\DrugDataBase`

Observed on 2026-05-25:

- Zipped source files include full XML, structures, drug links, target polypeptide IDs, and FASTA sequences.
- Unzipped `full database.xml` is about 1.78 GiB and exported by DrugBank version `5.1` on 2026-03-05.
- `drug links.csv`: 19,842 lines including header.
- `all.csv`: 5,097 lines including header, target/gene/protein associations.
- `pharmacologically_active.csv`: 1,470 lines including header.

Recommended role:

- Scientific enrichment layer, not the primary Chinese consumer label source.
- Source for international identifiers, CAS numbers, external links, targets, genes, proteins, mechanisms, pathways, and interaction/risk enrichment where license permits.
- Used by backend tools and AI retrieval, not shipped to Flutter clients.

## 3. Which layer owns what

| Concern | Owner | Reason |
| --- | --- | --- |
| Full xlsx import | Backend import pipeline | Dataset is too large for Flutter assets and needs validation/deduplication. |
| DrugBank XML parsing | Backend import pipeline | Streaming parse is required; client-side use is not acceptable. |
| Authoritative medicine detail | PostgreSQL | Needs queryability, indexes, auditability, and API access. |
| Search index | PostgreSQL first | Use `pg_trgm`, full-text/search documents, and raw SQL through Prisma where needed. |
| Hot search/detail cache | Redis | Cache only derived or short-lived responses; do not make Redis a primary database. |
| User health data | PostgreSQL | Users, reminders, scan history, reports, observations, and long-term timelines need relational integrity. |
| Offline app cache | Flutter local database later | Use only for user-owned offline data and small cached snapshots; do not bundle the full knowledge base. |
| Markdown rendering | Flutter UI + backend formatted fields | Backend should return structured sections and/or sanitized Markdown; Flutter displays it consistently. |
| AI reasoning | Backend AI/Copilot modules | AI must retrieve from the knowledge base, cite source fields, and avoid becoming the source of truth. |

## 4. Backend target stack

Target backend stack:

- NestJS as the application framework.
- PostgreSQL as the primary persistent database.
- Prisma as the default typed data access and migration tool.
- Redis for verification codes, cooldowns, short-lived sessions/cache, and selected AI result cache.
- Passport with JWT strategy for auth guards; add local/code strategies only where they simplify auth flow.
- `class-validator` / `class-transformer` with Nest `ValidationPipe` for request DTO validation.

Rules:

- Preserve `/api/*` paths and `{ code, msg, result }` during migration.
- Keep Prisma as the main ORM, but allow raw SQL for Chinese search, trigram ranking, and full-text ranking.
- Do not mix Prisma and TypeORM in the same backend.
- Do not use Redis as a second medicine database.
- Keep large source datasets outside Git and import them through scripts.

## 5. PostgreSQL data model direction

The schema below is conceptual. Exact column names should be finalized in Prisma schema after an import sample proves the mapping.

### 5.1 Medicine product catalog

Use the Chinese xlsx as the first-class product catalog.

Recommended tables:

- `medicine_products`: one row per xlsx product/package row.
- `medicine_instruction_sections`: normalized long instruction fields such as ingredients, indications, dosage, adverse reactions, contraindications, precautions, special populations, interactions, pharmacology, pharmacokinetics, overdose, storage, and validity period.
- `medicine_categories`: main/subcategory normalization.
- `medicine_images`: image URL and cache/proxy metadata if later needed.
- `medicine_identifiers`: approval number, national drug code, barcode, source URL, and external identifiers.
- `medicine_search_documents`: generated searchable text and rank metadata.

Search keys:

- product name, brand/trademark, approval number, manufacturer, drug type, category, barcode, national drug code.
- Add `pg_trgm` GIN indexes for fuzzy Chinese search on product name, brand, manufacturer, approval number, and national drug code.
- Build a generated/search document column for multi-field ranking.

### 5.2 DrugBank enrichment

Use DrugBank as a linked enrichment graph.

Recommended tables:

- `drugbank_drugs`: DrugBank ID, name, type, description, CAS, state, groups, external IDs.
- `drugbank_targets`: target/gene/protein metadata from CSV and XML.
- `drugbank_drug_targets`: many-to-many relation between drugs and targets.
- `drugbank_interactions`: drug-drug interaction text when available and allowed.
- `drugbank_external_links`: KEGG, PubChem, ChEBI, PharmGKB, UniProt, RxList, Drugs.com, Wikipedia, and similar references.
- `medicine_drugbank_links`: mapping from Chinese products to DrugBank entities using active ingredient, CAS, external IDs, and manual review status.

Mapping rule:

- Do not assume a Chinese product equals one DrugBank drug just because names look similar.
- Link by active ingredient/CAS/external ID first, then use reviewed fuzzy matching as a fallback.
- Keep mapping confidence and review status.

### 5.3 User health and copilot data

Long-term Personal Health Copilot features need their own user-owned data model:

- `health_profiles`: baseline profile, allergies, chronic conditions, pregnancy/lactation status, age group, and risk flags.
- `health_reports`: uploaded report metadata, OCR text, structured metrics, source file metadata.
- `health_observations`: symptoms, pain scores, vitals, mood, sleep, diet, activity, and measurement source.
- `medicine_response_logs`: `medicine -> symptom/vital change -> time delta` records.
- `care_tasks`: AI- or user-created follow-up actions with explicit confirmation state.
- `share_tokens`: time-limited doctor/family share links.
- `audit_events`: important access and AI output events.

## 6. Markdown strategy

Markdown should become the standard display format for long medical text, but structured data remains the source of truth.

Flutter packages to add later:

- `flutter_markdown` for rendering Markdown content.
- Optional: `markdown` if custom parsing or sanitization is needed on the client.

Backend packages or utilities to evaluate:

- A Markdown sanitizer/renderer only if server-side preview or HTML export is required.
- Otherwise, generate Markdown from safe structured fields and keep HTML out of API responses.

API result direction:

```json
{
  "id": "medicine-product-id",
  "productName": "...",
  "identifiers": {
    "approvalNo": "...",
    "drugCode": "...",
    "barcode": "..."
  },
  "sections": [
    {
      "key": "dosage",
      "title": "用法用量",
      "content": "..."
    }
  ],
  "detailMarkdown": "## 用法用量\n\n..."
}
```

Rules:

- Store canonical section content as structured text.
- Generate Markdown from sections at import time or request time.
- Use Markdown for layout and readability, not as the only data representation.
- AI output should use Markdown by default, but must include source references or source field names when it is based on retrieved data.

## 7. AI role after the new databases

The new data makes old "AI detail generation" less important. Authoritative drug facts should come from PostgreSQL, not a model.

### 7.1 De-emphasize or retire

- Generic `AI 药品详情`: replace with database-backed detail + deterministic Markdown.
- Model-generated label sections: do not ask AI to invent dosage, contraindication, or interaction facts that already exist in the catalog.

### 7.2 Keep and expand

AI should move into copilot workflows:

- Plain-language explanation of a medicine detail page, grounded in the selected structured sections.
- Medication safety review across the user's current medicines, allergies, age group, pregnancy/lactation status, and DrugBank interaction/enrichment data.
- Report interpretation from OCR/structured lab metrics, with "not a diagnosis" boundaries.
- Personal care-plan drafting: reminders, follow-up questions, doctor-visit summaries, and checklists.
- Symptom-response analysis: compare medication records, symptom logs, and vitals over time.
- Family/doctor share summaries: short Markdown summaries for time-limited share pages.

### 7.3 Backend module placement

Recommended Nest modules:

- `MedicinesModule`: search, product detail, instruction sections, scan candidates.
- `KnowledgeModule`: import status, source metadata, source mapping, DrugBank enrichment lookup.
- `AiModule`: model gateway, prompt registry, output parser, safety guardrails.
- `CopilotModule`: user-facing AI workflows that combine user context + retrieved knowledge.
- `SafetyModule`: deterministic and AI-assisted medicine safety checks.
- `ReportsModule`: report upload/OCR/structured metric extraction and explanation.
- `HealthTimelineModule`: observations, response logs, and long-term analytics.

## 8. Import and migration phases

### Phase A: Data audit and legal boundary

- Record source paths, file sizes, exported dates, row counts, checksums, and license notes.
- Confirm whether DrugBank usage terms allow the intended local development, demo, and deployment use.
- Keep `D:\DrugDataBase\FullDrugDetail.xlsx` and `D:\DrugDataBase` outside Git.
- Create a small synthetic/sample import fixture for tests.

### Phase B: PostgreSQL schema and staging import

- Add Prisma schema for staging tables first.
- Import xlsx rows into `staging_medicine_products`.
- Stream DrugBank XML into staging tables; never load the full XML into memory.
- Add import reports with source count, success count, failure count, and sample failure reasons.

### Phase C: Normalization and linking

- Normalize xlsx rows into medicine product, instruction section, identifier, category, and search document tables.
- Normalize DrugBank drugs, targets, external IDs, and interaction data.
- Build `medicine_drugbank_links` with confidence and review status.

### Phase D: API parity and Flutter contract

- Keep existing medicine search/detail routes compatible.
- Add richer fields behind the same response or a versioned result shape.
- Return `sections` and `detailMarkdown`.
- Keep old Flutter screens working before replacing UI widgets.

### Phase E: Markdown UI

- Add Flutter Markdown rendering in medicine detail and AI/copilot output surfaces.
- Replace hand-written text segment regex with structured sections + Markdown rendering.
- Add widget tests for long section rendering and safety disclaimer visibility.

### Phase F: AI responsibility shift

- Deprecate generic AI detail generation.
- Add copilot endpoints for explanation, safety review, report interpretation, and health timeline summaries.
- Enforce citations/source sections and disclaimer rules in AI prompts and response DTOs.

### Phase G: Legacy data retirement

- Remove MySQL as the medicine source after PostgreSQL import and route parity are validated.
- Keep `lib/assets/data.json` as a two-row development fixture only or replace it with a generated test fixture.
- Do not reintroduce a full medicine JSON asset into Flutter.

## 9. Validation gates

Data import validation:

- xlsx source row count equals imported staging row count or differences are explained.
- Required fields are measured for null/empty rates.
- Duplicate approval number, barcode, and national drug code behavior is documented.
- Import scripts are idempotent.

Backend validation:

- Prisma migration runs from an empty PostgreSQL database.
- Search/detail API tests cover product name, approval number, manufacturer, barcode, and national drug code.
- DrugBank import tests use a small fixture, not the full XML.
- Redis cache can be cleared without losing primary data.

Flutter validation:

- Medicine detail can render long Markdown sections without overflow.
- AI/copilot output renders Markdown and keeps safety disclaimer visible.
- Existing smoke flow still covers launch, auth navigation, and medicine search/detail.

## 10. Immediate next steps

1. Finish Flutter Phase 0 foundation and minimal `integration_test` smoke.
2. Add backend Phase 0 contract tests for current medicine search/detail/AI routes.
3. Draft Prisma schema for xlsx staging and normalized medicine product tables.
4. Build a read-only import prototype against a copied/sampled xlsx, not the production file path.
5. Add Markdown rendering only after API contracts define `sections` and `detailMarkdown`.
