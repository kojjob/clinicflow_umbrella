# ClinicFlow – Glossary

> **Version:** 1.0  
> **Last Updated:** December 3, 2025  

This glossary defines key terms used consistently across all ClinicFlow documentation.

---

## Patient Flow Terms

| Term | Definition |
|------|------------|
| **Patient** | An individual seeking medical attention at the clinic |
| **Visit** | A single patient interaction from check-in to checkout |
| **Check-in** | The process of registering a patient's arrival at the clinic |
| **Checkout** | The process of completing a patient's visit |
| **No-show** | A patient who does not appear when called or within the expected window |
| **Recall** | A notification sent to bring a patient back to the waiting area |

---

## Queue Terms

| Term | Definition |
|------|------------|
| **Queue** | An ordered list of patients waiting to be seen |
| **Queue Entry** | A patient's position and status in the waiting queue |
| **Position** | The numerical order of a patient in the queue |
| **ETA** | Estimated Time of Arrival — predicted wait time until patient's turn |

---

## Triage Levels

| Level | Priority | Definition | Visual Color |
|-------|----------|------------|--------------|
| **Emergency** | 1 (highest) | Life-threatening condition requiring immediate attention | 🔴 Red |
| **Urgent** | 2 | Serious condition requiring prompt attention | 🟠 Orange |
| **Routine** | 3 (lowest) | Standard consultation, no urgency | 🟢 Green |

Triage levels determine queue sorting order. Emergency patients are seen first, then Urgent, then Routine. Within each level, patients are ordered by arrival time.

---

## Patient Status

| Status | Definition | Previous | Next |
|--------|------------|----------|------|
| **Waiting** | Patient is in the queue, not yet seen | (initial) | In Room |
| **In Room** | Patient is with a doctor in a consultation room | Waiting | Done |
| **Done** | Visit completed, patient has left | In Room | (terminal) |

Status transitions must follow this order. Skipping states is not allowed.

---

## Room Status

| Status | Definition | Previous | Next |
|--------|------------|----------|------|
| **Available** | Room is ready for the next patient | Cleaning | Busy |
| **Busy** | Room is occupied with a patient consultation | Available | Cleaning |
| **Cleaning** | Room is being prepared for the next patient | Busy | Available |
| **Out of Service** | Room is not available for use | Any | Any |

---

## Organization Terms

| Term | Definition |
|------|------------|
| **Organization** | A clinic business entity; the top-level account in ClinicFlow |
| **Branch** | A physical clinic location belonging to an organization |
| **Multi-branch** | An organization with more than one physical location |
| **Staff Membership** | Association of a user with an organization in a specific role |

---

## Roles & Permissions

| Role | Level | Scope | Key Capabilities |
|------|-------|-------|------------------|
| **Owner** | 4 | Organization-wide | Full access including billing, all branches, all staff |
| **Manager** | 3 | Assigned branch(es) | Branch operations, staff management (limited), analytics |
| **Doctor** | 2 | Assigned branch | Patient queue, consultations, personal analytics |
| **Receptionist** | 1 | Assigned branch | Queue operations, patient check-in, notifications |

Higher-level roles inherit capabilities of lower-level roles within their scope.

---

## Subscription Terms

| Term | Definition |
|------|------------|
| **Plan** | A pricing tier with defined feature limits (branches, staff, etc.) |
| **Subscription** | An organization's active plan enrollment |
| **Trial** | Initial period where all features are available before payment required |
| **Active** | Subscription in good standing with current payment |
| **Past Due** | Payment failed; grace period before suspension |
| **Canceled** | Subscription terminated; limited access |
| **Billing Interval** | Payment frequency: monthly or yearly |

---

## Notification Terms

| Term | Definition |
|------|------------|
| **Notification** | A message sent to a patient via SMS or WhatsApp |
| **Template** | A reusable message format with placeholders |
| **Placeholder** | A variable in a template replaced with actual data (e.g., `{patient_name}`) |
| **Opt-in** | Patient has consented to receive notifications |
| **Opt-out** | Patient has declined to receive notifications |

### Common Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{patient_name}` | Patient's display name | "John D." |
| `{position}` | Current queue position | "3" |
| `{eta}` | Estimated wait time | "15 minutes" |
| `{clinic_name}` | Clinic/branch name | "Downtown Clinic" |
| `{room_number}` | Assigned room | "Room 5" |

---

## Technical Terms

| Term | Definition |
|------|------------|
| **LiveView** | Phoenix framework for real-time server-rendered UI |
| **PubSub** | Publish-Subscribe pattern for broadcasting real-time updates |
| **Oban** | Background job processing library for Elixir |
| **Context** | Phoenix pattern for grouping related business logic |
| **Changeset** | Ecto structure for validating and tracking data changes |
| **Multi** | Ecto structure for database transactions with multiple operations |

---

## Audit Terms

| Term | Definition |
|------|------------|
| **Audit Log** | Record of administrative actions for accountability |
| **Actor** | The user who performed an audited action |
| **Target** | The entity affected by an audited action |
| **Changes** | The before/after values for an audited modification |

---

## Analytics Terms

| Term | Definition |
|------|------------|
| **Wait Time** | Duration from check-in to consultation start |
| **Consultation Time** | Duration from consultation start to completion |
| **Throughput** | Number of patients processed in a given period |
| **Peak Hours** | Time periods with highest patient volume |
| **No-show Rate** | Percentage of patients who don't appear for their turn |
| **Doctor Productivity** | Patients seen per doctor per time period |

---

## Abbreviations

| Abbreviation | Full Form |
|--------------|-----------|
| **ETA** | Estimated Time of Arrival |
| **GDPR** | General Data Protection Regulation |
| **PHI** | Protected Health Information |
| **SaaS** | Software as a Service |
| **SLA** | Service Level Agreement |
| **CRUD** | Create, Read, Update, Delete |
| **API** | Application Programming Interface |
| **SMS** | Short Message Service |
| **UI** | User Interface |
| **KPI** | Key Performance Indicator |
