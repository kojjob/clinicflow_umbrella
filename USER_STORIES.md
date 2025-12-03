# ClinicFlow – User Stories

> **Version:** 1.1  
> **Last Updated:** December 3, 2025  
> **Status:** Approved  

---

## Epic 1: Queue Management

### Receptionist Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-001 | As a **Receptionist**, I want to add a patient quickly, so that I can minimize wait times at check-in. | - Patient form takes <30 seconds to complete<br>- Required fields: name, phone, reason for visit<br>- Auto-generates queue position |
| US-002 | As a **Receptionist**, I want to assign a triage level (Routine/Urgent/Emergency), so that critical patients are seen first. | - Three triage options available<br>- Emergency auto-jumps queue<br>- Visual indicator shows triage level |
| US-003 | As a **Receptionist**, I want to see patient ETA, so that I can inform patients of expected wait time. | - ETA displayed next to each patient<br>- ETA updates in real-time<br>- Accuracy within ±5 minutes |
| US-004 | As a **Receptionist**, I want to send "return to clinic" messages, so that patients who stepped out can return on time. | - One-click message sending<br>- Uses configured SMS/WhatsApp provider<br>- Message status visible (sent/delivered) |
| US-005 | As a **Receptionist**, I want to mark patients as no-show, so that the queue reflects actual attendance. | - No-show button available after 15-minute wait<br>- Patient removed from active queue<br>- No-show logged for analytics |

---

## Epic 2: Doctor Workflow

### Doctor Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-011 | As a **Doctor**, I want to see who is next in my queue, so that I can prepare for the next patient. | - Next patient displayed prominently<br>- Shows patient name, triage level, wait time<br>- Updates in real-time |
| US-012 | As a **Doctor**, I want to pull patients into my room, so that they are marked as being seen. | - One-click "Start Consultation" button<br>- Room status changes to "Busy"<br>- Patient status changes to "In Room" |
| US-013 | As a **Doctor**, I want to see my daily workload, so that I can pace myself appropriately. | - Total patients assigned today<br>- Patients seen vs remaining<br>- Average consultation time |
| US-014 | As a **Doctor**, I want to know how many patients are left, so that I can estimate my end time. | - Remaining patient count visible<br>- Estimated completion time shown<br>- Updates as queue changes |
| US-015 | As a **Doctor**, I want to mark a consultation as complete, so that the next patient can be called. | - "Complete" button ends consultation<br>- Room status changes to "Cleaning" or "Available"<br>- Patient status changes to "Done" |

---

## Epic 3: Notifications

### Patient Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-017 | As a **Patient**, I want to receive SMS updates, so that I stay informed without asking staff. | - SMS sent when position changes significantly<br>- Message includes current position and ETA<br>- Opt-out link included |
| US-018 | As a **Patient**, I want to know my estimated wait time, so that I can plan my time. | - Wait time shown on check-in receipt<br>- Updates via SMS when ETA changes >10 min<br>- Displayed on waiting room screen |
| US-019 | As a **Patient**, I want to be notified when I am next, so that I can prepare for my consultation. | - "You're next" SMS/WhatsApp sent<br>- Sent when 1 patient ahead<br>- Includes room number if assigned |
| US-020 | As a **Patient**, I want to check in via self-service kiosk, so that I don't have to wait in line. | - Touch-screen friendly interface<br>- Phone number lookup for returning patients<br>- Prints queue ticket with position |
| US-021 | As a **Patient**, I want to provide feedback after my visit, so that I can help improve the clinic. | - SMS survey link sent post-visit<br>- Simple 1-5 star rating<br>- Optional comment field |

---

## Epic 4: Waiting Room Display

### System Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-023 | As a **System**, I want to display the queue on a waiting room screen, so that patients can see their position. | - Full-screen kiosk mode<br>- Shows next 10-15 patients<br>- Auto-refreshes every 5 seconds |
| US-024 | As a **System**, I want to anonymize patient names, so that privacy is protected. | - Shows "John D." instead of "John Doe"<br>- Configurable anonymization level<br>- GDPR compliant |
| US-025 | As a **System**, I want to color-code triage levels, so that urgency is visually clear. | - Red = Emergency<br>- Orange = Urgent<br>- Green = Routine |

---

## Epic 5: Analytics & Reports

### Manager Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-028 | As a **Manager**, I want to view wait time analytics, so that I can identify bottlenecks. | - Daily/weekly/monthly views<br>- Average, min, max wait times<br>- Breakdown by triage level |
| US-029 | As a **Manager**, I want to see doctor productivity metrics, so that I can balance workloads. | - Patients seen per doctor<br>- Average consultation time<br>- Comparison across doctors |
| US-030 | As a **Manager**, I want to identify peak hours, so that I can optimize staffing. | - Hourly patient volume chart<br>- Day-of-week patterns<br>- Exportable data |
| US-031 | As a **Manager**, I want to track no-show rates, so that I can implement reminders. | - No-show percentage<br>- Trends over time<br>- Breakdown by appointment type |
| US-032 | As a **Manager**, I want to export reports as CSV/PDF, so that I can share with stakeholders. | - One-click export<br>- Customizable date range<br>- Includes charts and tables |

---

## Epic 6: Owner Portal

### Clinic Owner Stories

| ID | User Story | Acceptance Criteria |
|----|------------|---------------------|
| US-034 | As a **Clinic Owner**, I want to configure my clinic profile, so that branding is consistent. | - Upload logo<br>- Set clinic name and contact info<br>- Configure timezone |
| US-035 | As a **Clinic Owner**, I want to add/edit branches, so that I can manage multiple locations. | - Create new branch with address/phone<br>- Assign staff to branches<br>- Enable/disable branches |
| US-036 | As a **Clinic Owner**, I want to manage staff roles, so that access is appropriately controlled. | - Assign roles: Owner, Manager, Doctor, Receptionist<br>- Role-based permissions enforced<br>- Invite staff via email |
| US-037 | As a **Clinic Owner**, I want to configure rooms and queue types, so that they match our physical setup. | - Add/edit/remove rooms per branch<br>- Set room capacity and type<br>- Configure queue behavior |
| US-038 | As a **Clinic Owner**, I want to customize notification templates, so that messages reflect our brand. | - Edit SMS/WhatsApp templates<br>- Use placeholders (patient name, ETA)<br>- Preview before saving |
| US-039 | As a **Clinic Owner**, I want to view analytics across branches, so that I can compare performance. | - Multi-branch dashboard<br>- Drill down to individual branch<br>- Compare metrics side-by-side |
| US-040 | As a **Clinic Owner**, I want to manage subscription & billing, so that I can control costs. | - View current plan<br>- Upgrade/downgrade options<br>- Update payment method |
| US-041 | As a **Clinic Owner**, I want to view invoices and payment history, so that I can track expenses. | - List of all invoices<br>- Download PDF invoices<br>- Payment status visible |
| US-042 | As a **Clinic Owner**, I want to access audit logs, so that I can ensure accountability. | - Log of all admin actions<br>- Filter by user, action, date<br>- Export capability |
| US-043 | As a **Clinic Owner**, I want to disable or enable staff access, so that I can manage departures. | - Suspend/reactivate accounts<br>- Immediate access revocation<br>- Audit trail maintained |

---

## Story Status Legend

| Status | Meaning |
|--------|---------|
| 🔴 Not Started | Story not yet in sprint |
| 🟡 In Progress | Currently being developed |
| 🟢 Complete | Deployed and accepted |
| ⚪ Blocked | Waiting on dependency |

---

## Backlog (Post-MVP)

| ID | User Story | Priority |
|----|------------|----------|
| US-050 | As a **Patient**, I want to book appointments online, so that I don't have to call the clinic. | P1 |
| US-051 | As a **Doctor**, I want voice-assisted triage, so that I can speed up assessments. | P2 |
| US-052 | As a **System**, I want AI-driven wait time prediction, so that ETAs are more accurate. | P2 |
| US-053 | As a **Owner**, I want EMR/EHR integration, so that patient data flows automatically. | P1 |
| US-054 | As a **Staff**, I want a mobile app, so that I can manage queues on the go. | P2 |
