# UniProcure — University E-Procurement & Vendor Management Portal
## Enterprise Frontend System Specification & Technical Capabilities Report

**Document Status:** Complete & Executive Ready  
**Version:** 1.0.0 (Release-Ready Web Architecture)  
**Target Audience:** Institutional Stakeholders, Procurement Evaluation Committees, Technical Partners, Investors  
**Scope:** Frontend Architecture, Client Technologies, Role-Based Functionalities, Web Security Strategy & Future Roadmap *(Backend specifications provided independently)*  

---

## 1. Executive Summary & Value Proposition

### 1.1 Project Overview
**UniProcure** is an enterprise-grade, institutional e-procurement and vendor management web portal designed specifically for modern higher education institutions, research universities, and public sector academic bodies. The platform digitizes and governs the complete procurement lifecycle—from requisition initiation and public tender publication to multi-tier administrative approvals, algorithmic bid evaluation, contract execution, and treasury disbursals.

### 1.2 Core Business Objectives
* **Public Procurement Compliance:** Built strictly in alignment with public procurement frameworks (Public Procurement Act / Rules), enforcing statutory safeguards such as minimum 3-quote participation, competitive bidding transparency, and rigid budget caps.
* **Radical Financial Transparency:** Eliminates backroom tampering and manual paper leaks by maintaining immutable digital audit trails across all administrative evaluation milestones.
* **Automated Merit-Based Selection:** Replaces subjective bias with automated Quality and Cost-Based Selection (QCBS) comparative matrices that combine technical compliance with financial scoring.
* **Operational Cycle Time Reduction:** Compresses requisition-to-sanction timelines from weeks to days via automated escalation timers, role-based cockpit dashboards, and instant status tracking.
* **Interactive Live Demonstration Capability:** Engineered with an integrated reactive client database engine (`DummyDatabaseService`), allowing complete, interactive zero-backend demonstrations for board-level pitches and stakeholder negotiations without server dependencies.

---

## 2. Frontend Software Technology Stack

The client application is built with modern cross-platform web technologies configured for high-performance enterprise delivery:

| Technology Layer | Framework / Library | Version | Technical Purpose & Architectural Justification |
| :--- | :--- | :--- | :--- |
| **Core Client Engine** | **Flutter Web (SDK)** | `^3.24+ / Dart 3.12+` | Single codebase compiled directly to web standards. Provides pixel-perfect visual fidelity, desktop-class rendering performance, and cross-browser consistency. |
| **Application Architecture** | **Clean Architecture + DDD** | Standardized | Strict separation of concerns into Presentation, Domain, and Data layers. Completely decouples UI widgets from business logic and data sources. |
| **State Management & DI** | **GetX** | `^4.7.2` | High-performance reactive micro-state management (`Rx`, `Obx`), declarative dependency injection (`GetxService`, `Get.lazyPut`), and decoupled named route management. |
| **Networking & HTTP** | **Dio** | `^5.7.0` | Robust HTTP client featuring connection pooling, custom authentication interceptors, request timeout guards, and retry mechanics. |
| **Resilience & Fault Tolerance** | **Custom RetryInterceptor** | In-house | Automated request retries with exponential backoff and network jitter calculation for unstable connectivity environments. |
| **Developer Observability** | **PrettyDioLogger** | `^1.4.0` | Compact console tracing for HTTP request/response lifecycles, headers, query parameters, and network errors. |
| **Client-Side Storage** | **GetStorage** | `^2.1.1` | Fast, lightweight, synchronous key-value storage engine operating over HTML5 Web Storage (`localStorage`) without mobile-native plugin lockups. |
| **Functional Error Monads** | **Dartz** | `^0.10.1` | Functional programming abstractions (`Either<Failure, T>`) guaranteeing compile-time error handling and eliminating unhandled runtime exceptions. |
| **Document & Asset Picking** | **FilePicker** | `^12.2.0` | Secure web-compatible document selection supporting binary byte streams for PDF quotation, trade license, and invoice uploads. |
| **Responsive Data Grids** | **DataTable2** | `^2.5.15` | Desktop-grade data table engine with pinned sticky headers, horizontal scrolling, column-level sorting, and custom cell renders. |
| **Data Visualization & Analytics** | **FL Chart** | `^1.2.0` | Hardware-accelerated charting library powering institutional spend breakdowns, monthly trend curves, and fiscal budget comparisons. |
| **Modern Typography** | **Google Fonts (Inter)** | `^8.2.1` | Curated sans-serif typography ensuring institutional clarity, readability, and visual hierarchy across high-density data tables. |
| **Date & Currency Formatting** | **Intl** | `^0.20.3` | Localization and internationalization engine formatting multi-currency values and standardized timestamps. |
| **Notification System** | **Toastification** | `^3.2.0` | Multi-tiered visual alert notifications featuring progress timers, swipe dismissal, and actionable micro-interactions. |
| **Build & Edge Deployment** | **Vercel & Custom Bash** | Edge CDN | Automated continuous deployment pipeline with custom build scripts (`vercel-build.sh`) and client-side single page app rewrites (`vercel.json`). |

---

## 3. UI/UX Design System & Adaptive Layout Engine

The user interface adheres to institutional design standards tailored for complex corporate software:

* **Curated Institutional Color Palette:** Built around authoritative University Blue (`#1A56DB`), Slate Charcoal (`#0F172A`), Emerald Success (`#16A34A`), and Amber Warning (`#F59E0B`). Avoids generic raw primaries in favor of balanced HSL-derived functional tokens.
* **Three-Tier Adaptive Breakpoint System:**
  * **Desktop (≥ 1200px):** Permanent 260px administrative sidebar, dual-pane analytics grids, full-width multi-column data tables with pinned action rows.
  * **Tablet (600px – 1199px):** Collapsible 72px icon rail with auto-expansion on hover (220px), wrapping summary cards, and horizontally scrollable comparison matrixes.
  * **Mobile (< 600px):** Elevation-zero AppBar, collapsible slide-over Drawer navigation, single-column responsive cards, and sticky action bottoms.
* **Permission-Gated Navigation:** Sidebar and drawer menus dynamically recalculate items based on the logged-in user's role—preventing cognitive clutter and accidental unauthorized clicks.

---

## 4. Comprehensive Features & Functionalities by Persona

UniProcure provides five specialized user roles, each equipped with an isolated operational cockpit and role-specific workflows:

```
+-----------------------------------------------------------------------------------+
|                                 UniProcure Portal                                 |
+-----------------------------------------------------------------------------------+
       |                    |                     |                 |
       v                    v                     v                 v
[ Institutional ]    [ Requisition ]       [ Multi-Tiered ]    [ Registered ]    [ Finance &  ]
[ Administrator ]    [  Initiator  ]       [  Approvers   ]    [  Vendors   ]    [  Treasury  ]
       |                    |                     |                 |                  |
* Staff Directory    * Create Circular    * Dept Head        * Tender Browsing   * 3-Way Match
* Vendor Approvals   * BOQ Specifications * Faculty Dean     * Online Quoting    * EFT Direct Payout
* Policy Tiers       * Budget Cap Check   * Registrar / VC   * Bid Tracker       * Budget Ledgers
* Spend Analytics    * Bid Monitoring     * History Tracker  * Work Order Invoicing
```

---

### 4.1 Persona 1: Institutional Administrator (System Admin)

The System Admin controls enterprise governance, security policies, and institutional oversight:

#### A. User Account & Permission Management
* **Staff Directory Grid:** Searchable, filterable list of all university internal accounts (Initiators, Deans, Registrar, Finance Officers).
* **Instant Account State Toggle:** Single-click activation and deactivation of staff access with immediate session termination.
* **Role Reassignment:** Dynamic elevation of permissions across academic departments.

#### B. Statutory Vendor Verification Queue
* **Verification Workflow:** Dedicated queue displaying newly registered commercial entities awaiting onboarding review.
* **Statutory Compliance Checks:** Comprehensive modal displaying the vendor's Tax Identification Number (TIN), Trade License Number, VAT Registration Certificate, Bank Solvency Certificate, and contact credentials.
* **Formal Decisioning:** Capabilities to Approve (promotes vendor to `ACTIVE` state with verification timestamp and officer signature) or Reject (with mandatory reason log).

#### C. Dynamic Workflow Hierarchy & Governance Engine
* **Hierarchical Financial Sanction Thresholds:** Interactive configuration of procurement tiers:
  * *Tier 1 (Department Head):* Up to \$25,000 (Routine departmental consumables & minor lab supplies).
  * *Tier 2 (Faculty Dean):* \$25,001 to \$100,000 (Major IT infrastructure & lab equipment).
  * *Tier 3 (Registrar / Vice Chancellor):* Above \$100,000 (Institutional capital expenditures & campus-wide contracts).
* **Auto-Escalation Timing Rules:** Configurable inactivity threshold (default: 5 business days) that automatically flags overdue requests.
* **Statutory Governance Toggles:**
  * *Enforce 3 Minimum Responsive Quotations:* Disallows comparison matrix generation until at least 3 qualifying vendors bid.
  * *Strict Departmental Budget Ceiling Enforcement:* Blocks circular authoring if department allocation is exhausted.
  * *Public Display Window Duration:* Configurable mandatory bidding period (7 to 30 days).

#### D. Executive Analytics & Reporting Cockpit
* **8-Point Institutional KPI Suite:** Real-time visibility into Total Spend, Annual Fiscal Budget, Active Tenders, Registered Vendors, Pending Approvals, Verification Queue, Approval Turnaround, and On-Time Delivery Compliance.
* **Spend by Category Distribution:** Visual breakdown across Scientific & Lab Equipment, IT & Campus Networking, Heavy Workshop Machinery, Smart Classroom AV, and Office Automation.
* **Monthly Spend & Tender Trends:** 6-month historical expenditure velocity curves.
* **Vendor Performance Leaderboard:** Ranked index of top university suppliers based on contract volume, milestone SLA compliance, and lab evaluation ratings.

---

### 4.2 Persona 2: Requisition Initiator (Department Heads / Lab Directors)

The Initiator authors procurement requests and monitors fulfillment:

#### A. Requisition & Circular Authoring Engine
* **Structured Data Entry:** Requisition title, originating department, category, estimated budget ceiling, and submission closing dates.
* **Itemized Bill of Quantities (BOQ):** Detailed item specification, technical parameters, unit requirements, and estimated unit costs.
* **Document Attachment Support:** Uploading technical drawings, terms of reference (TOR), and tender terms.

#### B. Tender Lifecycle Tracking
* **Real-Time Status Indicators:** Visual chip states (`Draft`, `Published`, `Evaluation`, `Pending Approver`, `Approved`, `Awarded`).
* **Bid Participation Radar:** Live counter showing the number of participating vendor bids submitted against the circular.

#### C. Completed Project Archives
* **Historical Audit Repository:** Comprehensive log of archived tenders, awarded contracts, delivery sign-offs, and final payouts.

---

### 4.3 Persona 3: Multi-Tiered Approvers (Dept Head, Dean, Registrar)

Hierarchical academic leaders responsible for vetting expenditure:

#### A. Centralized Pending Approvals Queue
* **Priority Escalation View:** Highlighted approval requests sorted by monetary threshold and urgency.
* **Pre-Evaluation Summaries:** Quick glance cards displaying circular title, originating department, requested allocation, and committee lead.

#### B. Direct Evaluation Matrix Access
* **Context-Driven Review:** Single-click navigation from the approval request directly into the full vendor comparison matrix.
* **Bidder Lineage Inspection:** Ability to review all competing vendor prices, delivery schedules, and technical scores before authorizing.

#### C. Action Decisioning Cockpit
* **Formal Approval Action:** Sanctions the expenditure, automatically advancing the circular to the subsequent tier or to final `AWARDED` status.
* **Rejection with Mandatory Comments:** Returns the requisition with specific policy or budget critique.
* **Request for Clarification / Resubmission:** Routes circular back to Initiator for specification amendment without terminating the tender.

#### D. Approval Progress Tracker
* **Visual Stepper Timeline:** Step-by-step audit diagram illustrating each approval stage, indicating officer identity, action timestamp, and recorded rationale.

---

### 4.4 Persona 4: Registered Vendors (Contractors & Suppliers)

Commercial partners participating in institutional tenders:

#### A. Vendor Onboarding & Self-Service Portal
* **Digital Registration:** Submission of enterprise legal profile, incorporation details, and authorized representative data.
* **Statutory Document Repository:** Document uploading for Trade License, TIN, and VAT certificates.
* **Account Status Tracking:** Visual notification banners indicating `Pending Verification`, `Active`, or `Correction Required`.

#### B. Public Tender Discovery
* **Active Circular Explorer:** Searchable, categorized tender listings detailing requirements, deadlines, and eligibility terms.
* **Tender Detail Modal:** Complete access to technical specifications and downloadable procurement guidelines.

#### C. Competitive Quotation Submission Engine
* **Bid Input Form:** Total quoted commercial price, promised calendar delivery timeline, and warranty duration.
* **Technical Compliance Attestation:** Checkbox legal certification guaranteeing adherence to specifications.
* **Proposal Attachment:** Multi-file attachment for technical proposal dossiers, catalog cut-sheets, and OEM manufacturer authorization certificates.

#### D. Bid Portfolio & Work Order Dashboard
* **'My Bids' Tracker:** Real-time feedback on submitted bids (`Under Evaluation`, `Qualified`, `Awarded`, `Disqualified`).
* **Contract Work Orders:** Overview of awarded contracts, delivery terms, and milestone requirements.
* **Invoice Claim Submission:** Uploading delivery challans and commercial tax invoices for completed supplies.

---

### 4.5 Persona 5: Finance & Treasury Officers

University financial controllers who oversee budget integrity and disbursements:

#### A. Treasury & Fiscal Governance Cockpit
* **Annual Budget Burn Tracking:** Visual tracking of Total Fiscal Budget (\$3.5M baseline), Committed Liabilities, Disbursed Payments, and Uncommitted Balance.
* **EFT Direct Settlement Rate:** Real-time metric monitoring BEFTN / RTGS electronic bank clearance percentages.

#### B. 3-Way Matching & Invoice Claim Audit
* **Automated 3-Way Match Verification:** Cross-comparison between:
  1. Original Awarded Purchase Order Amount.
  2. Initiator Lab Delivery Acceptance Note.
  3. Vendor Commercial Tax Invoice.
* **Discrepancy Highlighting:** Color-coded warning badges when invoice figures deviate from contract terms.

#### C. Disbursement Processing
* **Approve & Settle Payment:** Generates an official Electronic Funds Transfer (EFT) transaction reference and logs the disbursing officer's credentials.
* **Return for Clarification:** Flags missing challans or tax calculation errors back to the vendor.

---

### 4.6 Standalone Feature: Automated Bid Comparison Matrix (QCBS)

A signature capability of UniProcure is its automated evaluation matrix:

* **Quality & Cost-Based Selection (QCBS) Model:** Combines Technical Scoring (e.g., 70% weight) and Financial Scoring (e.g., 30% weight) into an automated Composite Score.
* **Automatic Budget Delta Calculation:** Computes financial difference relative to the institution's approved ceiling.
* **Lowest Price Highlight:** Automated green banner highlighting the most economically advantageous tender.
* **Committee Recommendation Output:** Automatically synthesizes formal award recommendations for submission to the Faculty Dean and Registrar.

---

## 5. Web Production Readiness & Security Strategy for Flutter Web

Publishing a Flutter Web enterprise application properly and securely requires addressing web-specific considerations:

```
+---------------------------------------------------------------------------------+
|                       Production Flutter Web Architecture                       |
+---------------------------------------------------------------------------------+
          |                                                   |
          v                                                   v
[ Performance & Rendering ]                         [ Web Security Hardening ]
  * CanvasKit Engine with Local Caching               * Strict Content Security Policy (CSP)
  * Font Subsetting & Web Workers                     * HTTP Strict Transport Security (HSTS)
  * Tree-Shaken Release Bundles                       * In-Memory Token Handling + Secure Cookies
  * Gzip/Brotli Edge Compression                      * Anti-XSS Sanitization & Byte Validations
```

### 5.1 Rendering Engine Optimization
* **Renderer Selection:** Built for deployment using Flutter's **CanvasKit** renderer (`flutter build web --release --no-wasm-dry-run`). CanvasKit leverages Skia compiled to WebAssembly (WASM), ensuring that high-density data tables, graphs, and font metrics render identically across Chrome, Safari, Firefox, and Edge.
* **CanvasKit Pre-caching:** Host the `canvaskit.wasm` and `canvaskit.js` binaries on the application CDN to eliminate third-party CDN lookup latencies and comply with strict intranet security regulations.
* **Service Worker Caching Strategy:** The application includes a cache-busting registration script in `web/index.html` ensuring that when newer releases are deployed, obsolete service workers and assets are automatically evicted from browser cache.

### 5.2 Enterprise Web Security Architecture
To deploy UniProcure securely into production, the following frontend security configurations must be applied at the edge server / CDN layer:

#### A. Content Security Policy (CSP)
A rigid CSP header must be configured on the host server (e.g. Vercel, Nginx, Cloudflare) to prevent Cross-Site Scripting (XSS) and arbitrary code injection:

```http
Content-Security-Policy: default-src 'self'; 
  script-src 'self' 'wasm-unsafe-eval' https://fonts.googleapis.com; 
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; 
  font-src 'self' https://fonts.gstatic.com; 
  img-src 'self' data: blob: https:; 
  connect-src 'self' http://localhost:8000 https://api.uniprocure.edu; 
  object-src 'none'; 
  frame-ancestors 'none'; 
  base-uri 'self'; 
  form-action 'self';
```

#### B. Additional Security Headers
* **HSTS (HTTP Strict Transport Security):** `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload` forces encrypted TLS communication.
* **X-Content-Type-Options:** `nosniff` blocks MIME-type sniffing.
* **X-Frame-Options:** `DENY` protects against clickjacking attacks.
* **Referrer-Policy:** `strict-origin-when-cross-origin` shields private query parameters from leaking to external referrers.

#### C. Client-Side Authentication & Session Hardening
* **Storage Protection:** Access tokens are managed via `StorageService` using abstracted keys. In production web mode, tokens should never be stored in plaintext `window.localStorage` if vulnerable to third-party scripts. The recommended architecture pairs short-lived in-memory JWTs with HTTP-Only, Secure, SameSite=Strict cookies for refresh operations.
* **Client-Side Permission Guards:** `AuthGuard` and `PermissionService.canAccess()` evaluate role tokens prior to route transitions. Any unauthorized deep link (e.g., a vendor navigating directly to `/admin/workflow-settings`) is immediately intercepted and routed to safe fallbacks.
* **Automatic Session Eviction:** Inactivity timeouts automatically invoke `logout()`, flushing cached user profiles and redirecting to `/login`.

#### D. Input Sanitization & Payload Verification
* **Strict Client Form Validators:** All inputs (quotations, delivery days, TIN, contact details) pass through regex-based validators (`lib/core/utils/validators.dart`) before submission.
* **File Upload Defense:** Document uploads are capped at 5 MB (`AppConstants.maxUploadSizeBytes`), with strict extension whitelisting (`['pdf', 'jpg', 'jpeg', 'png']`) and binary MIME sniffing before dispatch to API endpoints.

---

## 6. Strategic Product Roadmap (Future Enhancements)

To expand commercial scope and close institutional contracts, the following high-value enhancements represent the strategic roadmap for subsequent development phases:

```
[ PHASE 1: COMPLIANCE ] ──> [ PHASE 2: AUTOMATION ] ──> [ PHASE 3: SCALE ]
* PKI Digital Signatures     * Real-time WebSockets      * Multi-Campus Federation
* Automated Tax Withholding  * Native PDF Generation    * Anti-Collusion Analytics
```

### Phase 1: Cryptographic Digital Signatures & e-Signatures
* **Objective:** Enable legally binding approvals under National Digital Signature Acts.
* **Functionality:** Approving Deans and Registrars can sign sanction orders and comparative statements using digital certificate signatures (PKI X.509) or enterprise e-sign integrations (DocuSign / Adobe Sign API).

### Phase 2: Real-Time Event Streaming & Push Notifications
* **Objective:** Eliminate manual polling for deadline countdowns and urgent reviews.
* **Functionality:** Integration of WebSockets / Server-Sent Events (SSE) to broadcast real-time tender closure alerts, outbid notifications to suppliers, and instant approval requests to academic executives.

### Phase 3: In-Browser Client PDF & Excel Reporting Engine
* **Objective:** Allow one-click generation of audit-compliant documentation without server latency.
* **Functionality:** Generating printable Purchase Orders, Comparative Evaluation Statements, and Treasury Disbursement Ledgers directly in the client using client-side PDF rendering.

### Phase 4: Automated Tax (AIT), VAT & Statutory Withholding Engine
* **Objective:** Prevent accounting errors in vendor claims.
* **Functionality:** Dynamic calculation engine that automatically deducts Advanced Income Tax (AIT) and Value Added Tax (VAT) at source according to statutory government revenue brackets prior to EFT clearing.

### Phase 5: Supplier Performance Scorecard & Predictive Risk Index
* **Objective:** Protect the university from delinquent contractors.
* **Functionality:** Algorithmic vendor rating that penalizes suppliers for delivery delays, defect ratios, and SLA violations, automatically factoring historical scores into future bid evaluations.

### Phase 6: Multi-Campus Federation & Departmental Sub-Ledgers
* **Objective:** Scale to university systems with distributed medical colleges, regional campuses, and autonomous institutes.
* **Functionality:** Multi-tenant organization selector allowing institutional switching under unified administration.

---

## 7. Build, Deployment & Verification Summary

### 7.1 Production Build Command
To produce the release-ready static web bundle for deployment:
```bash
flutter build web --release --no-wasm-dry-run --pwa-strategy=none
```

### 7.2 Hosting Infrastructure
* **Hosting Target:** Vercel Global Edge Network / AWS CloudFront / Nginx Enterprise.
* **Rewrites:** Fully configured in `vercel.json` to route all virtual paths (`/(.*)`) to `/index.html` for HTML5 browser history navigation.

---

*Report prepared by the Engineering & Product Architecture Team for Institutional Stakeholder Demonstration.*
