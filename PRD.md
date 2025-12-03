# ClinicFlow – Product Requirements Document (PRD)

> **Version:** 1.2  
> **Last Updated:** December 3, 2025  
> **Status:** Approved  
> **Author:** Product Team  

---

## Table of Contents
1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Goals](#goals)
4. [Target Users](#target-users)
5. [Core Features (MVP)](#core-features-mvp)
6. [Non-Functional Requirements](#non-functional-requirements)
7. [Success Metrics](#success-metrics)
8. [Assumptions & Constraints](#assumptions--constraints)
9. [Out of Scope (MVP)](#out-of-scope-mvp)
10. [Future Roadmap](#future-roadmap)
11. [Glossary](#glossary)

---

## Overview

ClinicFlow is a real-time patient queue & clinic operations SaaS built with **Elixir + Phoenix + LiveView**.

It solves waiting room chaos by providing:
- Digital queue management
- Doctor room assignment
- SMS/WhatsApp notifications
- Digital waiting room screen
- Real-time workload dashboards
- Owner Portal for multi-branch management, billing, analytics & configuration

---

## Problem Statement

Small & mid-sized clinics lack modern workflow tools. They rely on:
- Paper lists and manual tracking
- Verbal name-calling in waiting rooms
- No workload balancing across doctors
- No performance visibility or analytics
- No multi-branch oversight for clinic chains

**Impact:**
- Patient wait times 2-3x longer than necessary
- 15-25% no-show rates
- Staff burnout from manual coordination
- Lost revenue from inefficient room utilization

ClinicFlow replaces this with a reliable, real-time, cloud-based system.

---

## Goals

### Functional Goals
| Priority | Goal |
|----------|------|
| P0 | Manage queues digitally with triage-based prioritization |
| P0 | Real-time updates for doctors & reception via LiveView |
| P0 | Patient notifications via SMS/WhatsApp |
| P1 | Analytics & downloadable reports |
| P1 | Owner Portal for organization management |
| P1 | Subscription & billing management |

### Business Goals
- Global SaaS rollout with multi-tenant architecture
- Low entry friction: <10 minute onboarding
- Strong retention via actionable analytics
- Upsell path from single clinic to multi-branch

---

## Target Users

### Primary Users

| Role | Description | Key Needs |
|------|-------------|-----------|
| **Receptionist** | Front desk staff managing patient check-in | Fast patient entry, queue visibility, notification sending |
| **Doctor** | Medical practitioners seeing patients | Next patient view, room management, workload visibility |
| **Clinic Owner/Manager** | Business owners or operations managers | Multi-branch oversight, analytics, billing, staff management |

### Secondary Users

| Role | Description | Key Needs |
|------|-------------|-----------|
| **Patient** | Individuals visiting the clinic | Wait time visibility, SMS updates, feedback submission |
| **Internal Support** | ClinicFlow support team | Tenant management, troubleshooting |

---

## Core Features (MVP)

### 1. Queue Management (P0)
- Patient creation with basic demographics
- Add to queue with triage level (Routine/Urgent/Emergency)
- Auto-prioritization by triage + arrival time
- Status flow: Waiting → In Room → Done
- Real-time queue updates via PubSub

### 2. Doctor Workflow (P0)
- "Next patient" one-click workflow
- Room assignment and status tracking
- Real-time dashboard updates via LiveView
- Daily workload visibility

### 3. Notifications (P0)
- SMS/WhatsApp alerts via Twilio or Africa's Talking
- Configurable notification templates
- "Return to clinic" recall messages
- Opt-in/opt-out preferences per patient

### 4. Waiting Room Display (P1)
- Full-screen kiosk mode
- Partial name anonymization (GDPR compliant)
- Color-coded triage indicators
- Auto-refresh every 5 seconds

### 5. Analytics & Reporting (P1)
- Daily/monthly performance reports
- Doctor throughput metrics
- Queue time trends and bottleneck analysis
- Peak hours identification
- No-show rate tracking
- CSV/PDF export

### 6. Owner Portal (P1)
- Organization & clinic profile management
- Branch management (add/edit/disable)
- Staff & role management (Owner > Manager > Doctor > Receptionist)
- Room & queue configuration
- Notification template customization
- Subscription & billing (Stripe/Paddle integration)
- Invoice history and payment management
- Audit logs for accountability
- Multi-branch analytics dashboard

---

## Non-Functional Requirements

### Performance
| Requirement | Target |
|-------------|--------|
| LiveView update latency | <100ms |
| Page load time | <2 seconds |
| Concurrent users per clinic | 50+ |

### Availability
| Requirement | Target |
|-------------|--------|
| Uptime SLA | ≥99.9% |
| Planned maintenance window | <4 hours/month |

### Security
| Requirement | Implementation |
|-------------|----------------|
| Data encryption | TLS 1.3 in transit, AES-256 at rest |
| Password policy | Minimum 8 chars, complexity requirements |
| Session management | 24-hour expiry, secure cookies |
| Data isolation | Multi-tenant with organization-level separation |
| GDPR compliance | Pseudonymization of PHI, data export, deletion requests |
| Audit logging | All admin actions logged with actor, timestamp, changes |

### Scalability
- Horizontal scaling via Kubernetes
- Database: PostgreSQL with read replicas
- Background jobs: Oban with configurable concurrency

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Queue update latency | <100ms | LiveView performance monitoring |
| Onboarding time | <10 minutes | Time from signup to first patient added |
| No-show rate reduction | 50% | Compare before/after implementation |
| Daily active clinics | ≥95% | Login activity tracking |
| Average wait time reduction | 30–50% | Analytics dashboard data |
| NPS score | ≥40 | Quarterly surveys |
| Churn rate | <5% monthly | Subscription analytics |

---

## Assumptions & Constraints

### Assumptions
- Clinics have reliable internet connectivity
- Staff have basic computer/tablet literacy
- Patients have mobile phones capable of receiving SMS
- Clinics operate during defined hours (not 24/7 for MVP)

### Constraints
- MVP targets English language only
- SMS/WhatsApp requires provider account setup
- Billing integration requires Stripe or Paddle account
- Maximum 10 branches per organization in MVP

### Dependencies
| Dependency | Provider | Purpose |
|------------|----------|---------|
| SMS delivery | Twilio / Africa's Talking | Patient notifications |
| WhatsApp | Twilio / Meta Business API | Patient notifications |
| Billing | Stripe / Paddle | Subscription management |
| Email | SendGrid / Postmark | Transactional emails |
| Hosting | Fly.io / AWS | Application deployment |

---

## Out of Scope (MVP)

The following are explicitly **not** included in MVP:
- Patient self-check-in kiosk (Post-MVP)
- AI-driven wait time prediction
- EMR/EHR integrations
- Mobile native apps (iOS/Android)
- Telehealth/video consultations
- Appointment scheduling (walk-in only for MVP)
- Multi-language support (i18n)
- Offline mode
- API for third-party integrations

---

## Future Roadmap

### Phase 2 (Post-MVP)
- Patient self-check-in kiosk
- Appointment scheduling system
- Patient feedback & surveys
- Advanced analytics with AI insights
- API for third-party integrations

### Phase 3
- Mobile app for staff
- EMR/EHR integrations
- Telehealth integration
- Multi-language support (i18n)

### Phase 4
- AI-driven wait-time prediction
- Voice-assisted triage
- Corporate multi-clinic dashboards
- Custom branding options (white-label)
- Gamification for staff performance

---

## Glossary

| Term | Definition |
|------|------------|
| **Triage** | Classification of patient urgency: Routine, Urgent, or Emergency |
| **Visit** | A single patient interaction from check-in to checkout |
| **Queue Entry** | A patient's position in the waiting queue |
| **Room Status** | Current state of a consultation room: Available, Busy, or Cleaning |
| **Patient Status** | Current state in visit flow: Waiting, In Room, or Done |
| **Branch** | A physical clinic location belonging to an organization |
| **Organization** | A clinic business entity, may have multiple branches |
| **Staff Membership** | Association of a user with an organization in a specific role |
| **ETA** | Estimated Time of Arrival for patient's turn |
| **No-show** | A patient who doesn't appear when called |
| **Recall** | Message sent to bring a patient back to the waiting area |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial PRD |
| 1.1 | Nov 2025 | Added Owner Portal to MVP |
| 1.2 | Dec 2025 | Added prioritization, assumptions, glossary, out-of-scope |
