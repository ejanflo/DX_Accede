# DX_ACCEDE (Accede - Expense Management System)

Comprehensive enterprise web application for managing:
- Request For Payment (RFP)
- Travel & Non-Travel Expense Reports (Liquidation & Reimbursement)
- Non-PO Invoices (Payment to Vendor)
- Multi-level Workflow Approvals (Regular + FAP / Financial Approval)
- File Attachments & Document Preview (PDF, DOCX, Images)
- Email Notifications & Status Tracking
- Audit / Cashier / P2P processing views

Built on ASP.NET WebForms (.NET Framework 4.7.2, C# 7.3) with DevExpress UI components and LINQ to SQL (ITPORTAL database schema).

---
## Key Features

| Domain | Highlights |
|--------|------------|
| RFP (Request For Payment) | Multi-transaction types (Cash Advance, Reimbursement, Vendor), workflow routing, SAP Doc No. capture (Cashier), recall capability |
| Expense Reports | Aggregation of expense lines, CA application, auto reimbursement generation, workflow + FAP workflow |
| Travel Expense | Cash Advance linkage, foreign/domestic logic, reimbursement netting (Due To Company / Employee), allowance & categorized expense mappings |
| Workflow Engine | Dual-layer WF: Main WF + FAP WF (Financial Approval), activity tracking via `ITP_T_WorkflowActivities` |
| Document Handling | Upload + storage in `ITP_T_FileAttachment`; modal viewer with pdf.js / docx.js / image embedding |
| Security & Session | Session-based access control via `AnfloSession`; page-level guards; role-dependent UI sections |
| Notifications | Dynamic email templates (status-based) using content from `ITP_S_Texts` |
| Performance | Per-request row caching (HttpContext.Items), static concurrent dictionary caching for document types |

---

## Technology Stack

- Runtime: .NET Framework 4.7.2
- Language: C# 7.3
- UI: ASP.NET WebForms + DevExpress (ASPxGridView, ASPxFormLayout, etc.)
- ORM: LINQ to SQL (`ITPORTALDataContext`)
- Front-End Libraries:
  - jQuery (AJAX operations)
  - pdf.js (2.6.347 CDN)
  - docx.js (Word document rendering)
  - Bootstrap Icons (for modal headers)
- Reporting: DevExpress XtraReports (e.g., `AccedeTravelMain`)
- Email: Custom formatter (`ANFLO.Email_Content_Formatter`)
- Caching: In-memory (per-request + static dictionaries)

---

## Core Domain Entities (Selected)

| Table / Entity | Purpose |
|----------------|---------|
| `ACCEDE_T_RFPMains` | RFP master (amount, transaction type, workflow linkage) |
| `ACCEDE_T_ExpenseMains` | Expense Report master (totals, WF references) |
| `ACCEDE_T_TravelExpenseMains` | Travel Expense master (foreign/domestic, timing) |
| `ITP_T_WorkflowActivities` | Workflow instance activities (status progression) |
| `ITP_T_FileAttachments` | Binary file storage & metadata |
| `ITP_S_Status` | Canonical status catalog |
| `ITP_S_DocumentTypes` | Application document type registry |

---

## Workflow Model

1. Document creation assigns:
   - Main Workflow (`WF_Id`)
   - Financial Approval Workflow (`FAPWF_Id`) when thresholds apply.
2. First approver sequence inserted into `ITP_T_WorkflowActivities`.
3. Status transitions (e.g., Saved → Pending → Returned → Disbursed) follow `STS_Id` values sourced from `ITP_S_Status`.
4. Reimbursement or Cash Advance components create companion RFP entities (link via `Exp_ID` or `isTravel`).

---

## Document Viewer

AJAX Pattern:
- JavaScript calls e.g. `DocumentViewer.aspx/AJAXGetDocument`
- C# `[WebMethod]` retrieves file (`ITP_T_FileAttachment`)
- Response:
  - Images: Base64 string
  - PDF/DOCX: Raw byte array
- Front-End:
  - pdf.js renders pages → `<canvas>` per page (`RenderPage`)
  - docx.js `renderAsync` for Word
  - Images inserted as `<img class='img-fluid'>`

Security Note: No direct path exposure; content streamed from database.

---

## Session & Security

| Mechanism | Behavior |
|-----------|----------|
| `AnfloSession.Current.ValidCookieUser()` | Gate each page load |
| Session Keys | `userID`, `ExpenseId`, `passRFPID`, `TravelExp_Id`, workflow context IDs |
| Recall Logic | Allowed if document still at initial/pending stage |

Recommendation: Abstract session access to reduce scattering & add null safety.

---

## Notable Code Practices

| Pattern | Example |
|---------|---------|
| Safe conversion | `SafeToInt(object)` helper in `AllAccedeP2PPage` |
| Per-request caching | `GetOrAddRowCache` with `HttpContext.Items` |
| Static cross-request cache | `_docTypeNameCache` (ConcurrentDictionary) |
| Caution flagged | Base64 used as “encryption” placeholder (RFP & P2P pages) |

---

## Key WebMethods (AJAX Endpoints)

| Method | File | Purpose |
|--------|------|---------|
| `AJAXGetDocument` | Multiple (Viewer / RFP / Expense / Travel) | Retrieve file attachment |
| `UpdateRFPMainAjax` | RFPViewPage | Transition RFP status & seed workflow |
| `SaveCashierChangesAJAX` | RFPViewPage | Cashier updates SAP Doc or disbursement |
| `RecallRFPMainAJAX` / `RecallExpMainAJAX` | RFP / Expense | Document recall with remarks |
| `AddCA_AJAX` | AccedeExpenseReportEdit | Associate Cash Advances |
| `UpdateReimbursementAJAX` | AccedeExpenseReportEdit | Adjust reimbursement amount |
| `DisplayCADetailsAJAX` | AccedeExpenseViewPage | Load CA detail pop-up |
| `AJAXRecallDocument` | TravelExpenseView | Recall travel expense bundle |

All return simple DTOs or anonymous objects suitable for JSON consumption.

---

## Business Logic Highlights

### Expense vs Cash Advance vs Reimbursement
- Expense lines aggregated → Net vs CA total determines:
  - “Net Due to Employee” (reimbursement generated / updated)
  - “Net Due to Company” (AR reference / settlement path)

### Travel Expense
- Categorization of allowances and reimbursable transport via mapping tables (`_TravelExpenseDetailsMaps`).
- Foreign vs Domestic toggles currency symbol and conditional fields.

### Cashier Processing
- SAP Doc No. assignment triggers status change (Pending SAP Doc No. → Disbursed).
- Buttons dynamically shown based on role (`Accede Cashier`) and workflow stage.

---

## Front-End Interaction Flow (Example: Viewing a File)

1. User clicks attachment row (DevExpress grid custom button).
2. JS calls `AJAXGetDocument`.
3. Response analyzed: contentType → viewer selection.
4. Modal assembled with icon + title.
5. Render function executes:
   - PDF: iterate pages with scale/resolution settings.
   - DOCX: `docx.renderAsync`.
   - Image: `<img src='data:image/...'>`.

---

## Setup & Installation

### Prerequisites
- Visual Studio 2022
- .NET Framework 4.7.2 Developer Pack
- DevExpress ASP.NET (matching version used in solution; ensure license)
- SQL Server instance with “ITPORTAL” schema + ACCEDE tables
- SMTP configuration (if emails should dispatch)

### Build
1. Open solution in Visual Studio 2022.
2. Restore DevExpress references (ensure proper version installed).
3. Build solution (Any CPU / x86 depending on legacy constraints).
4. Run via IIS Express or configure site in local IIS for integrated auth scenarios.

### Optional: PDF Worker Hosting
Current pdf.js worker served via CDN (`cdnjs.cloudflare.com`). For offline:
- Download `pdf.js` + worker
- Set `pdfjsLib.GlobalWorkerOptions.workerSrc = '/scripts/pdf.worker.min.js';`

---

## Deployment

| Step | Notes |
|------|-------|
| Precompile | Consider WebForms pre-compilation for production performance |
| Artifact | Deploy full site folder (bin + content) |
| IIS Configuration | Enable compression, set correct .NET Framework AppPool |
| Logging | Add application-level logging (missing in current code) |
| Security Hardening | Replace Base64 “encryption”; implement proper tokenization for querystring access (e.g., AES + HMAC) |

---

## Coding & Contribution Guidelines

| Guideline | Practice |
|-----------|----------|
| C# Style | Favor explicit `var` only when RHS is obvious |
| Null Safety | Continue using helper converters (e.g., `SafeToInt`) |
| Data Access | Keep single query projections; avoid `FirstOrDefault` followed by property indexing without null checks |
| Caching | Expand current dictionary caches for other reference tables (statuses, pay methods) where hot |
| JS Modules | Consolidate duplicated viewer logic (`docuviewer.js` vs `docviewer2.js`) |
| Security | Centralize session validation + access rights; consider HttpModule |

Pull Request Checklist:
- No secrets committed
- All WebMethods return deterministic JSON
- Database migrations/scripts documented
- Page-level permission verified

---

## Testing Recommendations

| Layer | Suggested Approach |
|-------|--------------------|
| Workflow | Seed test data for multi-sequence WF and assert status transitions |
| RFP Recall | Verify active activities are updated & email fired |
| Expense Netting | Matrix test (expense vs CA values) |
| Travel Expense | Foreign vs Domestic toggle; multi-currency scenarios |
| Attachment Rendering | Binary variations (large PDF, multi-page DOCX, image) |
| Cashier Flow | Pending SAP → assign doc no → Disbursed state |

---

## Future Enhancements

- Migrate to ASP.NET Core (modular services + EF Core)
- Introduce centralized API layer (REST) for AJAX operations
- Replace LINQ to SQL with modern ORM
- Implement token-based document access (signed URLs)
- Add structured logging (Serilog / ELK)
- Add unit/integration tests & CI pipeline
- Role-based component rendering via a policy service

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Viewer shows blank | Invalid blob type or corrupt file | Inspect response payload; ensure correct contentType mapping |
| Workflow not advancing | Missing first activity insert | Check creation logic & WF header configuration |
| Recall does nothing | No activity with Status=1 | Verify status & AppDocTypeId alignment |
| Attachments not visible | `SqlDataSource` parameters not set | Ensure SelectParameters populated before DataBind |
| SAP Doc not saving | Cashier section hidden | Verify role mapping in `vw_ACCEDE_FinApproverVerifies` |

---

## License / Attribution

Internal enterprise application (no public license specified).  
Third-party libraries:
- DevExpress (commercial)
- pdf.js (Apache 2.0)
- docx.js (MIT)
- jQuery (MIT)
- Bootstrap Icons (MIT)

Ensure compliance with respective licenses in distributed environments.

---

## Contact / Ownership

- Core Modules: ACCEDE Finance Automation
- Session / Security Integration: AnfloSession subsystem
- Email Templates: Managed via `ITP_S_Texts`
- For enhancements or issues: Submit via internal issue tracker / helpdesk.

---

## Appendix: Core JavaScript Viewer Functions (Summary)

| Function | Purpose |
|----------|---------|
| `ViewDocument(fileId, appId)` | AJAX fetch + dynamic viewer dispatch |
| `LoadPdfFromBlob(blob)` | pdf.js multi-page rendering |
| `LoadDocxFromBlob(file)` | docx.js asynchronous render |
| `RenderPage(container, pageNum)` | Renders individual PDF page with scaling |

---

This system was developed by RTGARCIA & EMALBURO from the IT Department of ANFLO Management and Investment Corporation.

