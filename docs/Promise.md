# Luminous Personal Health Copilot Vision

Last updated: 2026-05-25

## 1. Product position

Luminous is no longer planned as only a medicine search app or a medication reminder. The target is a personal and family health management copilot:

> Use authoritative medicine knowledge, personal health records, cross-device Flutter experiences, and guarded AI workflows to help users understand, manage, and share their health actions.

Core boundary:

- Luminous does not diagnose.
- Luminous does not replace doctors or prescriptions.
- Luminous translates, organizes, reminds, compares, and helps users prepare better health decisions.

## 2. Why the new data changes the plan

The project now has two much stronger data sources:

- `D:\DrugDataBase\FullDrugDetail.xlsx`: 204,844 rows of Chinese medicine product and label-style details, including dosage, contraindications, precautions, special population use, interactions, pharmacology, barcode, and national drug code.
- `D:\DrugDataBase`: DrugBank data, including a large XML knowledge base and target/protein/drug-link files.

This changes the role of AI:

- Drug facts should come from the database, not from model-generated guesses.
- Medicine detail pages should be rendered from structured fields and Markdown.
- AI should become a copilot layer that explains, compares, summarizes, and personalizes based on authoritative retrieved data and user context.

The detailed data architecture is tracked in `docs/knowledge-data-platform-plan.md`.

## 3. Experience vision by terminal

### Mobile app

Role: fast capture and daily execution.

- Scan medicine packages and search the medicine knowledge base.
- View medicine instructions as structured cards and Markdown sections.
- Create reminders and check in medication usage.
- Capture reports, symptoms, vitals, and medication response logs.
- Receive safe, limited AI explanations and follow-up suggestions.

### Web portal

Role: family care and time-limited sharing.

- Family dashboard for medication adherence and key health signals.
- Doctor sharing link with short-lived access token.
- Readable health timeline and medication summary before consultations.

### Desktop

Role: long-range health data bank.

- Large-screen medicine, symptom, report, and vitals analysis.
- Drag-and-drop report import.
- Multi-year health timeline and medicine-response comparison.

## 4. Core product stages

### Stage 1: Medication closed loop

Goal: make the medicine experience strong enough before broad health expansion.

- Search and scan medicine.
- Show database-backed medicine detail.
- Render long instructions with Markdown.
- Create medication plans and reminders.
- Record check-ins and response logs.
- Replace old AI detail generation with authoritative detail + optional plain-language explanation.

Technology focus:

- Finish Flutter Phase 0 project foundation.
- Add minimal integration smoke tests.
- Build the backend knowledge platform around PostgreSQL.
- Keep massive source datasets outside the Flutter app and outside Git.

### Stage 2: Medicine safety and personalization

Goal: turn medicine records into a personal safety layer.

- Cross-check current medicines, allergies, special population flags, and DrugBank enrichment.
- Summarize possible interaction or caution signals.
- Ask follow-up questions instead of giving diagnoses.
- Generate doctor-ready Markdown summaries.

### Stage 3: Report interpretation and health timeline

Goal: expand from medicine to personal health records.

- OCR and parse lab/physical-exam reports.
- Track abnormal metrics over time.
- Explain metrics in plain language with source boundaries.
- Link reports, symptoms, medicines, and vitals into a timeline.

### Stage 4: Family and clinician collaboration

Goal: make health data shareable without losing privacy control.

- Family care dashboard.
- Temporary doctor access.
- Audit logs for viewed or shared data.
- Share summaries rather than raw private data by default.

## 5. Knowledge and AI principles

Authoritative sources:

- Chinese medicine product and instruction detail comes from PostgreSQL tables imported from the xlsx.
- Scientific enrichment comes from DrugBank-derived tables and reviewed mappings.
- User context comes from user-owned health records in PostgreSQL.

AI is allowed to:

- Explain database sections in simpler language.
- Summarize a selected medicine or user timeline.
- Compare medicines and user context with explicit uncertainty.
- Generate Markdown checklists and consultation summaries.
- Interpret reports with guardrails and disclaimer text.

AI is not allowed to:

- Invent dosage, contraindications, or interactions when structured data exists.
- Diagnose diseases.
- Recommend prescription changes without telling the user to consult a clinician.
- Hide uncertainty or omit source context.

## 6. Markdown direction

Markdown becomes the default long-text display format:

- Medicine instruction sections should support Markdown rendering.
- AI responses should be Markdown by default.
- Backend should return structured sections plus generated Markdown.
- Flutter should render Markdown consistently and keep safety disclaimers visible.

This replaces the current pattern of hand-written text segmentation and complex regular expressions.

## 7. Backend direction

Target backend:

- NestJS framework.
- PostgreSQL primary database.
- Prisma schema, migrations, and import scripts.
- Redis for verification codes, cooldowns, short-lived cache, and selected AI result cache.
- Passport JWT strategy for protected routes.
- LangChain/OpenAI-compatible gateway for AI calls.

The backend migration is tracked in `docs/backend-nestjs-pgsql-migration-plan.md`.

## 8. Competition and pitch framing

One-sentence pitch:

> Luminous is a cross-device personal health copilot that turns authoritative medicine knowledge and personal health records into safe, readable, actionable health management.

Problem:

- Medicine labels and health reports are hard to understand.
- Personal health records are scattered across apps, papers, hospitals, and family conversations.
- Medication adherence and real-world response are rarely recorded.
- AI health products are risky if they try to replace clinicians.

Solution:

- Authoritative drug knowledge base for medicine facts.
- Markdown explanations for readable details.
- AI copilot for explanation, summary, safety prompts, and health planning.
- Cross-device Flutter experience for capture, analysis, and sharing.

Moat:

- Structured Chinese medicine product knowledge plus DrugBank enrichment.
- Longitudinal personal response data.
- Clear safety boundary: not diagnosis, not prescription replacement.
- Cross-terminal execution from mobile to web to desktop.

## 9. Immediate execution focus

Do not jump directly into broad product expansion.

Current order:

1. Finish Flutter Phase 0 foundation.
2. Add minimal smoke tests.
3. Define backend contract tests.
4. Build PostgreSQL/Prisma import path for the new medicine knowledge source.
5. Add Markdown rendering to medicine detail and AI output surfaces.
6. Reposition AI detail into copilot workflows.
