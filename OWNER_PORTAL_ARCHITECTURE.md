# ClinicFlow – Owner Portal Architecture

> **Version:** 1.1  
> **Last Updated:** December 3, 2025  
> **Status:** Approved  

---

## Table of Contents
1. [Purpose](#purpose)
2. [System Design](#system-design)
3. [Data Model](#data-model)
4. [LiveView Pages](#liveview-pages)
5. [Permission System](#permission-system)
6. [Background Processes](#background-processes)
7. [API Extensions](#api-extensions)

---

## Purpose

The Owner Portal is the administrative control center for each clinic/organization using ClinicFlow.

It enables owners and managers to:
- Configure organization settings and branding
- Manage branches and rooms
- Assign staff roles and permissions
- Configure queues and triage settings
- Customize notification templates
- Manage subscription and billing
- View analytics and audit logs

---

## System Design

### Contexts Involved

| Context | Responsibility | Key Modules |
|---------|----------------|-------------|
| `ClinicFlow.Accounts` | Users, authentication, staff memberships | `User`, `StaffMembership` |
| `ClinicFlow.Orgs` | Organizations, branches, branding | `Organization`, `Branch` |
| `ClinicFlow.Rooms` | Room management, status tracking | `Room` |
| `ClinicFlow.Queues` | Queue configuration, triage rules | `Queue`, `QueueEntry`, `TriageLevel` |
| `ClinicFlow.Notifications` | Templates, SMS/WhatsApp settings | `NotificationTemplate`, `NotificationLog` |
| `ClinicFlow.Billing` | Plans, subscriptions, invoices | `Plan`, `Subscription`, `Invoice` |
| `ClinicFlow.Reports` | Aggregated analytics, exports | `ReportJob`, `ReportCache` |
| `ClinicFlow.Audit` | Audit logging, compliance | `AuditLog` |

### Context Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                      Owner Portal UI                         │
└─────────────────────────────────────────────────────────────┘
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ Accounts│ │  Orgs   │ │ Billing │ │ Reports │ │  Audit  │
   └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
        │           │                       │
        ▼           ▼                       ▼
   ┌─────────┐ ┌─────────┐           ┌─────────────┐
   │  Rooms  │ │ Queues  │           │Notifications│
   └─────────┘ └─────────┘           └─────────────┘
```

---

## Data Model

### Organization

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `name` | string | required, max 255 | Clinic/organization name |
| `slug` | string | required, unique | URL-friendly identifier |
| `logo_url` | string | optional | Path to uploaded logo |
| `primary_contact_email` | string | required, email format | Main contact email |
| `timezone` | string | required, default "UTC" | IANA timezone |
| `status` | enum | required | active, inactive, suspended |
| `settings` | jsonb | default {} | Configurable settings |
| `inserted_at` | datetime | auto | Creation timestamp |
| `updated_at` | datetime | auto | Last update timestamp |
| `deleted_at` | datetime | nullable | Soft delete timestamp |

**Indexes:** `slug` (unique), `status`

---

### Branch

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `organization_id` | UUID | FK, required | Parent organization |
| `name` | string | required, max 255 | Branch name |
| `address` | string | optional | Physical address |
| `phone` | string | optional | Contact phone |
| `status` | enum | required | active, inactive |
| `operating_hours` | jsonb | default {} | Hours by day of week |
| `inserted_at` | datetime | auto | Creation timestamp |
| `updated_at` | datetime | auto | Last update timestamp |
| `deleted_at` | datetime | nullable | Soft delete timestamp |

**Indexes:** `organization_id`, `status`

---

### StaffMembership

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `user_id` | UUID | FK, required | Associated user |
| `organization_id` | UUID | FK, required | Parent organization |
| `branch_id` | UUID | FK, nullable | Assigned branch (null = all) |
| `role` | enum | required | owner, manager, doctor, receptionist |
| `status` | enum | required | active, suspended, invited |
| `invited_at` | datetime | nullable | Invitation sent timestamp |
| `accepted_at` | datetime | nullable | Invitation accepted timestamp |
| `inserted_at` | datetime | auto | Creation timestamp |
| `updated_at` | datetime | auto | Last update timestamp |

**Indexes:** `user_id`, `organization_id`, unique on `[user_id, organization_id]`

---

### Plan

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `name` | string | required | Plan display name |
| `code` | string | required, unique | Internal plan code |
| `price_monthly` | integer | required | Price in cents (monthly) |
| `price_yearly` | integer | required | Price in cents (yearly) |
| `max_branches` | integer | required | Branch limit |
| `max_staff` | integer | required | Staff member limit |
| `features` | jsonb | default {} | Feature flags and limits |
| `is_active` | boolean | default true | Available for new signups |
| `inserted_at` | datetime | auto | Creation timestamp |
| `updated_at` | datetime | auto | Last update timestamp |

**Indexes:** `code` (unique), `is_active`

---

### Subscription

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `organization_id` | UUID | FK, required, unique | Subscribing organization |
| `plan_id` | UUID | FK, required | Selected plan |
| `status` | enum | required | trial, active, past_due, canceled |
| `billing_interval` | enum | required | monthly, yearly |
| `current_period_start` | datetime | required | Billing period start |
| `current_period_end` | datetime | required | Billing period end |
| `trial_ends_at` | datetime | nullable | Trial expiration |
| `cancel_at` | datetime | nullable | Scheduled cancellation |
| `canceled_at` | datetime | nullable | Actual cancellation time |
| `external_id` | string | nullable | Stripe/Paddle subscription ID |
| `inserted_at` | datetime | auto | Creation timestamp |
| `updated_at` | datetime | auto | Last update timestamp |

**Indexes:** `organization_id` (unique), `status`, `external_id`

---

### AuditLog

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PK | Primary identifier |
| `organization_id` | UUID | FK, required | Target organization |
| `actor_id` | UUID | FK, nullable | User who performed action |
| `actor_email` | string | required | Email at time of action |
| `action` | string | required | Action performed (e.g., "staff.created") |
| `target_type` | string | required | Schema name of target |
| `target_id` | UUID | nullable | ID of target record |
| `changes` | jsonb | default {} | Before/after values |
| `metadata` | jsonb | default {} | Additional context (IP, user agent) |
| `inserted_at` | datetime | auto | Action timestamp |

**Indexes:** `organization_id`, `actor_id`, `action`, `inserted_at`

---

### Soft Delete Strategy

All primary entities (Organization, Branch, Room, StaffMembership) support soft delete:

```elixir
# In schema
field :deleted_at, :utc_datetime

# In context
def soft_delete(record) do
  record
  |> change(deleted_at: DateTime.utc_now())
  |> Repo.update()
end

# In queries
def list_active(queryable) do
  from(q in queryable, where: is_nil(q.deleted_at))
end
```

---

## LiveView Pages

### `/owner/dashboard`

**Purpose:** High-level KPIs and branch comparison

| Component | Data Source | Refresh |
|-----------|-------------|---------|
| Patients Today (aggregate) | `Visits.count_today/1` | Real-time |
| Average Wait Time | `Reports.avg_wait_time/1` | 5 min cache |
| Branch Comparison Chart | `Reports.branch_metrics/1` | 5 min cache |
| Doctor Productivity Table | `Reports.doctor_stats/1` | 5 min cache |

**LiveView Events:**
- `handle_info({:visit_updated, visit})` - Increment patient count
- `handle_event("change_date_range", params)` - Filter data

---

### `/owner/branches`

**Purpose:** Branch CRUD operations

| Action | Permission | Audit |
|--------|------------|-------|
| List branches | owner, manager | No |
| Create branch | owner | Yes |
| Edit branch | owner, manager | Yes |
| Disable branch | owner | Yes |
| Delete branch | owner | Yes (soft) |

**Validations:**
- Branch count ≤ plan limit
- Unique name within organization

---

### `/owner/staff`

**Purpose:** Staff invitation and management

| Action | Permission | Audit |
|--------|------------|-------|
| List staff | owner, manager | No |
| Invite staff | owner, manager | Yes |
| Edit role | owner | Yes |
| Assign to branch | owner, manager | Yes |
| Suspend account | owner | Yes |
| Reactivate account | owner | Yes |

**Invitation Flow:**
1. Enter email and role
2. System creates StaffMembership with `status: :invited`
3. Email sent via Oban worker
4. User clicks link, creates account
5. StaffMembership updated to `status: :active`

---

### `/owner/rooms`

**Purpose:** Room configuration per branch

| Field | Validation |
|-------|------------|
| Name | Required, unique per branch |
| Type | consultation, procedure, triage |
| Capacity | Integer, default 1 |
| Status | Available, Busy, Cleaning, Out of Service |

---

### `/owner/settings`

**Purpose:** Organization configuration

**Sections:**
- **Profile:** Name, logo, contact email, timezone
- **Notifications:** Template editor, provider settings
- **Triage:** Customize triage levels and colors
- **Queue Behavior:** Auto-assignment rules, ETA calculation

---

### `/owner/billing`

**Purpose:** Subscription management

| Component | Source |
|-----------|--------|
| Current Plan | `Billing.get_subscription/1` |
| Usage Meters | `Billing.get_usage/1` |
| Payment Method | Stripe/Paddle API |
| Invoice List | `Billing.list_invoices/1` |

**Actions:**
- Upgrade/downgrade plan
- Update payment method (redirects to Stripe portal)
- Download invoice PDF
- Cancel subscription

---

### `/owner/audit`

**Purpose:** Action log review

**Filters:**
- Date range
- Actor (staff member)
- Action type
- Target type

**Export:** CSV download of filtered results

---

## Permission System

### Role Hierarchy

```
Owner (level 4)
  └── Manager (level 3)
       └── Doctor (level 2)
            └── Receptionist (level 1)
```

### Permission Matrix

| Resource | Action | Owner | Manager | Doctor | Receptionist |
|----------|--------|:-----:|:-------:|:------:|:------------:|
| Organization | View | ✅ | ✅ | ❌ | ❌ |
| Organization | Edit | ✅ | ❌ | ❌ | ❌ |
| Branch | View | ✅ | ✅* | ❌ | ❌ |
| Branch | Create | ✅ | ❌ | ❌ | ❌ |
| Branch | Edit | ✅ | ✅* | ❌ | ❌ |
| Branch | Delete | ✅ | ❌ | ❌ | ❌ |
| Staff | View | ✅ | ✅* | ❌ | ❌ |
| Staff | Invite | ✅ | ✅* | ❌ | ❌ |
| Staff | Edit Role | ✅ | ❌ | ❌ | ❌ |
| Staff | Suspend | ✅ | ❌ | ❌ | ❌ |
| Room | View | ✅ | ✅* | ✅* | ✅* |
| Room | Create/Edit | ✅ | ✅* | ❌ | ❌ |
| Queue | View | ✅ | ✅ | ✅* | ✅* |
| Queue | Manage | ✅ | ✅* | ❌ | ✅* |
| Analytics | View All | ✅ | ✅* | ❌ | ❌ |
| Analytics | View Own | ✅ | ✅ | ✅ | ❌ |
| Billing | View | ✅ | ❌ | ❌ | ❌ |
| Billing | Manage | ✅ | ❌ | ❌ | ❌ |
| Audit Log | View | ✅ | ✅* | ❌ | ❌ |

*\* Scoped to assigned branch only*

### Implementation

```elixir
defmodule ClinicFlow.Authorization do
  @moduledoc "Role-based access control"

  def authorize(user, action, resource) do
    membership = get_membership(user, resource)
    
    case {membership.role, action, resource} do
      {:owner, _, _} -> :ok
      {:manager, :view, %Branch{id: id}} when id == membership.branch_id -> :ok
      {:manager, :edit, %Branch{id: id}} when id == membership.branch_id -> :ok
      # ... additional rules
      _ -> {:error, :unauthorized}
    end
  end
end
```

**Enforcement Points:**
1. LiveView `mount/3` - Check page access
2. LiveView `handle_event/3` - Check action permission
3. Context functions - Verify before database operations

---

## Background Processes

### Oban Workers

| Worker | Queue | Schedule | Purpose |
|--------|-------|----------|---------|
| `InvoiceSyncWorker` | billing | Every 6 hours | Sync invoices from Stripe/Paddle |
| `SubscriptionCheckWorker` | billing | Daily | Check for past_due, handle grace period |
| `AnalyticsAggregationWorker` | reports | Nightly 2am | Pre-compute dashboard metrics |
| `AuditLogPruneWorker` | maintenance | Weekly | Remove logs older than retention period |
| `StaffInvitationWorker` | notifications | On demand | Send invitation emails |
| `NotificationWorker` | notifications | On demand | Send SMS/WhatsApp |

### Caching Strategy

| Data | Cache Key | TTL | Invalidation |
|------|-----------|-----|--------------|
| Dashboard metrics | `dashboard:#{org_id}:#{date}` | 5 min | Manual on significant change |
| Branch list | `branches:#{org_id}` | 10 min | On branch create/update/delete |
| Plan features | `plans:#{plan_id}` | 1 hour | On plan update |

---

## API Extensions (Phase 2)

### Authentication

All API endpoints require authentication via API key:

```
Authorization: Bearer <api_key>
```

API keys are scoped to organization and have configurable permissions.

### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/branches` | List branches |
| GET | `/api/v1/branches/:id/stats` | Branch performance |
| POST | `/api/v1/staff` | Create staff via HR integration |
| GET | `/api/v1/reports/daily` | Daily performance digest |

### Webhooks

| Event | Payload |
|-------|---------|
| `subscription.updated` | Plan changes, status updates |
| `branch.performance` | Daily metrics (configurable schedule) |
| `staff.invited` | New staff invitation sent |
| `staff.activated` | Staff accepted invitation |

### Rate Limits

| Plan | Requests/min | Requests/day |
|------|--------------|--------------|
| Starter | 60 | 10,000 |
| Professional | 120 | 50,000 |
| Enterprise | 300 | Unlimited |
