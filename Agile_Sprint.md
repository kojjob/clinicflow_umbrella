# ClinicFlow – Agile Epics & Sprint Plan

> **Version:** 1.1  
> **Last Updated:** December 3, 2025  
> **Status:** Approved  

## Methodology
- **Framework:** Agile Scrum  
- **Sprint Length:** 1 week  
- **MVP Duration:** 7 weeks  
- **Team Capacity:** TBD story points per sprint  

## Definition of Done (DoD)
- [ ] Code reviewed and approved
- [ ] Unit tests passing (≥80% coverage)
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Deployed to staging environment
- [ ] Product Owner acceptance

---

# EPIC 1 — Queue Management (Weeks 1–2)

**Goal:** Establish core queue infrastructure with real-time updates

## Sprint 1: Foundation
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-001 | Patient schema & CRUD | P0 |
| US-002 | Visit schema & CRUD | P0 |
| US-003 | Queue & QueueEntry schemas | P0 |
| US-004 | Triage categories (Routine/Urgent/Emergency) | P0 |
| US-005 | LiveView: Reception Queue Dashboard | P0 |

**Dependencies:** None  
**Risks:** Schema design changes may cascade to later sprints

## Sprint 2: Queue Intelligence
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-006 | Auto-sorting queue by triage + arrival | P0 |
| US-007 | ETA calculation | P1 |
| US-008 | State transitions: Waiting → In Room → Done | P0 |
| US-009 | PubSub real-time updates | P0 |
| US-010 | Property tests for queue ordering logic | P1 |

**Dependencies:** Sprint 1 complete  
**Risks:** ETA algorithm accuracy may need iteration

---

# EPIC 2 — Doctor Workflow (Week 3)

**Goal:** Enable doctors to efficiently process patients

## Sprint 3: Doctor Operations
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-011 | Room schema | P0 |
| US-012 | Assignment schema | P0 |
| US-013 | Doctor Dashboard LiveView | P0 |
| US-014 | "Next Patient" button functionality | P0 |
| US-015 | Room status management (Available/Busy/Cleaning) | P0 |
| US-016 | PubSub updates for doctors | P1 |

**Dependencies:** Epic 1 complete  
**Risks:** Room availability logic complexity

---

# EPIC 3 — Notifications (Week 4)

**Goal:** Keep patients informed via SMS/WhatsApp

## Sprint 4: Messaging System
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-017 | Notification schema | P0 |
| US-018 | SMS provider integration (Twilio/Africa's Talking) | P0 |
| US-019 | WhatsApp provider integration | P1 |
| US-020 | Notification templates (configurable) | P0 |
| US-021 | Oban background jobs for message delivery | P0 |
| US-022 | Opt-in/opt-out settings | P1 |

**Dependencies:** Patient schema from Epic 1  
**Risks:** Provider API rate limits; delivery failures

---

# EPIC 4 — Waiting Room Display (Week 5)

**Goal:** Provide public-facing queue visibility

## Sprint 5: Display Screens
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-023 | Waiting Room Display LiveView | P0 |
| US-024 | Anonymized patient name display (e.g., "John D.") | P0 |
| US-025 | Color-coded triage indicators | P1 |
| US-026 | Auto-refresh & kiosk mode | P0 |
| US-027 | Branch-specific queue views | P1 |

**Dependencies:** Queue system from Epic 1  
**Risks:** Display legibility at distance

---

# EPIC 5 — Analytics & Reports (Week 6)

**Goal:** Provide actionable insights for clinic operations

## Sprint 6: Reporting Engine
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-028 | Wait time calculations & trends | P0 |
| US-029 | Doctor productivity metrics | P0 |
| US-030 | Queue bottleneck analysis | P1 |
| US-031 | Peak hours visualization | P1 |
| US-032 | No-show rate tracking | P1 |
| US-033 | CSV/PDF export functionality | P0 |

**Dependencies:** Visit data from Epics 1-2  
**Risks:** Report generation performance for large datasets

---

# EPIC 6 — Owner Portal (Week 7)

**Goal:** Enable clinic owners to manage their organization

## Sprint 7: Administration Hub
| Story ID | Deliverable | Priority |
|----------|-------------|----------|
| US-034 | Organization schema | P0 |
| US-035 | Branch schema & management | P0 |
| US-036 | StaffMembership schema & roles | P0 |
| US-037 | Plan & Subscription schemas | P0 |
| US-038 | Owner Dashboard UI | P0 |
| US-039 | Branch Management UI | P1 |
| US-040 | Staff Management UI | P1 |
| US-041 | Billing integration (Stripe/Paddle) | P1 |
| US-042 | Notification Template configuration UI | P2 |
| US-043 | Audit logging system | P1 |
| US-044 | Permission system (Owner > Manager > Staff) | P0 |

**Dependencies:** All previous epics  
**Risks:** Complex sprint; may extend to Week 8

---

# Sprint Buffer (Week 8 — If Needed)

Reserved for:
- Bug fixes from testing
- Performance optimization
- Owner Portal completion
- Integration testing
- User acceptance testing

---

# Testing Strategy

| Phase | Type | Coverage Target |
|-------|------|-----------------|
| Sprint | Unit tests | ≥80% |
| Sprint | Integration tests | Critical paths |
| Week 7 | E2E tests | User journeys |
| Week 8 | Load testing | 100 concurrent users |
| Week 8 | Security audit | OWASP Top 10 |

---

# Retrospective Template

After each sprint:
1. **What went well?**
2. **What could be improved?**
3. **Action items for next sprint**
