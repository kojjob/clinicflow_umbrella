# AI Master Prompt – ClinicFlow Development Assistant

> **Version:** 1.1  
> **Last Updated:** December 3, 2025  

You are helping to build **ClinicFlow**, a real-time patient queue management SaaS using **Elixir, Phoenix, LiveView, Oban, Postgres**.

---

## Project Overview

ClinicFlow solves waiting room chaos for small and mid-sized clinics by providing:
- Digital queue management with triage-based prioritization
- Real-time doctor dashboards
- SMS/WhatsApp patient notifications
- Waiting room display screens
- Owner portal for multi-branch management

---

## Requirements

Generate the following artifacts when requested:
- Ecto schemas with proper types and validations
- Migrations with indexes and constraints
- Context modules following Phoenix conventions
- LiveView screens with real-time updates
- Supervisor trees for fault tolerance
- Oban workers for background jobs
- Test cases (unit, integration, property-based)
- API endpoints (JSON:API or REST)
- CI/CD configuration (GitHub Actions)
- Documentation in Markdown

---

## System Architecture

### Multi-Context Structure

```
lib/clinic_flow/
├── accounts/          # Users, authentication, staff memberships
│   ├── user.ex
│   ├── staff_membership.ex
│   └── accounts.ex
├── orgs/              # Organizations, branches
│   ├── organization.ex
│   ├── branch.ex
│   └── orgs.ex
├── patients/          # Patient records
│   ├── patient.ex
│   └── patients.ex
├── queues/            # Queue management, entries, triage
│   ├── queue.ex
│   ├── queue_entry.ex
│   ├── triage_level.ex
│   └── queues.ex
├── rooms/             # Room management
│   ├── room.ex
│   ├── assignment.ex
│   └── rooms.ex
├── notifications/     # SMS/WhatsApp messaging
│   ├── notification.ex
│   ├── notification_template.ex
│   └── notifications.ex
├── billing/           # Plans, subscriptions, invoices
│   ├── plan.ex
│   ├── subscription.ex
│   ├── invoice.ex
│   └── billing.ex
├── reports/           # Analytics and reporting
│   ├── report_job.ex
│   └── reports.ex
└── audit/             # Audit logging
    ├── audit_log.ex
    └── audit.ex
```

### LiveView Structure

```
lib/clinic_flow_web/live/
├── reception/
│   └── queue_live.ex          # Reception dashboard
├── doctor/
│   └── dashboard_live.ex      # Doctor workspace
├── display/
│   └── waiting_room_live.ex   # Public display
└── owner/
    ├── dashboard_live.ex      # Owner overview
    ├── branches_live.ex       # Branch management
    ├── staff_live.ex          # Staff management
    ├── rooms_live.ex          # Room configuration
    ├── settings_live.ex       # Organization settings
    ├── billing_live.ex        # Subscription management
    └── audit_live.ex          # Audit logs
```

---

## Functional Rules

### Queue Management
1. Queue auto-sorts by triage level (Emergency > Urgent > Routine) then by arrival time
2. Triage levels: `emergency` (priority 1), `urgent` (priority 2), `routine` (priority 3)
3. Emergency patients jump to front of queue immediately

### Patient Flow
4. Patient status transitions: `waiting` → `in_room` → `done`
5. Only valid transitions allowed (no skipping states)
6. State changes broadcast via PubSub

### Doctor Workflow
7. Doctors pull next patient with one click
8. Room status: `available` → `busy` → `cleaning` → `available`
9. Assignment links patient, room, and doctor

### Real-Time Updates
10. All dashboards use LiveView with PubSub broadcasts
11. Topic pattern: `queue:#{branch_id}` for branch-scoped updates
12. Waiting room display auto-refreshes every 5 seconds

### Notifications
13. SMS/WhatsApp sent via Oban workers (async)
14. Notification templates support placeholders: `{patient_name}`, `{position}`, `{eta}`
15. Respect patient opt-out preferences

---

## Code Style & Patterns

### Schema Patterns

```elixir
defmodule ClinicFlow.Queues.QueueEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "queue_entries" do
    field :position, :integer
    field :status, Ecto.Enum, values: [:waiting, :in_room, :done]
    field :triage_level, Ecto.Enum, values: [:emergency, :urgent, :routine]
    field :checked_in_at, :utc_datetime
    
    belongs_to :patient, ClinicFlow.Patients.Patient
    belongs_to :queue, ClinicFlow.Queues.Queue
    belongs_to :branch, ClinicFlow.Orgs.Branch
    
    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:position, :status, :triage_level, :checked_in_at])
    |> validate_required([:status, :triage_level])
    |> validate_status_transition()
  end

  defp validate_status_transition(changeset) do
    # Pattern match on valid transitions
    case {get_field(changeset, :status), get_change(changeset, :status)} do
      {_, nil} -> changeset
      {:waiting, :in_room} -> changeset
      {:in_room, :done} -> changeset
      {from, to} -> add_error(changeset, :status, "invalid transition from #{from} to #{to}")
    end
  end
end
```

### Context Patterns

```elixir
defmodule ClinicFlow.Queues do
  @moduledoc "Queue management context"
  
  import Ecto.Query
  alias ClinicFlow.Repo
  alias ClinicFlow.Queues.{Queue, QueueEntry}
  
  @doc "Get next patient in queue, sorted by triage + arrival"
  def next_patient(branch_id) do
    QueueEntry
    |> where([e], e.branch_id == ^branch_id and e.status == :waiting)
    |> order_by([e], [asc: e.triage_level, asc: e.checked_in_at])
    |> limit(1)
    |> Repo.one()
  end

  @doc "Add patient to queue with automatic position"
  def add_to_queue(attrs) do
    Multi.new()
    |> Multi.run(:position, fn repo, _ -> 
      {:ok, calculate_position(repo, attrs.branch_id)}
    end)
    |> Multi.insert(:entry, fn %{position: pos} ->
      QueueEntry.changeset(%QueueEntry{}, Map.put(attrs, :position, pos))
    end)
    |> Multi.run(:broadcast, fn _, %{entry: entry} ->
      broadcast_queue_update(entry)
      {:ok, entry}
    end)
    |> Repo.transaction()
  end
  
  defp broadcast_queue_update(entry) do
    Phoenix.PubSub.broadcast(
      ClinicFlow.PubSub,
      "queue:#{entry.branch_id}",
      {:queue_updated, entry}
    )
  end
end
```

### LiveView Patterns

```elixir
defmodule ClinicFlowWeb.Reception.QueueLive do
  use ClinicFlowWeb, :live_view
  
  alias ClinicFlow.Queues

  @impl true
  def mount(_params, session, socket) do
    branch_id = session["branch_id"]
    
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ClinicFlow.PubSub, "queue:#{branch_id}")
    end
    
    {:ok,
     socket
     |> assign(:branch_id, branch_id)
     |> assign(:queue, Queues.list_waiting(branch_id))}
  end

  @impl true
  def handle_info({:queue_updated, _entry}, socket) do
    # Refresh queue on any update
    {:noreply, assign(socket, :queue, Queues.list_waiting(socket.assigns.branch_id))}
  end

  @impl true
  def handle_event("add_patient", %{"patient" => params}, socket) do
    case Queues.add_to_queue(Map.put(params, "branch_id", socket.assigns.branch_id)) do
      {:ok, _entry} ->
        {:noreply, put_flash(socket, :info, "Patient added to queue")}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
```

### Error Handling

```elixir
# Use tagged tuples consistently
{:ok, result}
{:error, :not_found}
{:error, %Ecto.Changeset{}}
{:error, reason}

# In contexts, wrap database operations
def get_patient!(id), do: Repo.get!(Patient, id)
def get_patient(id), do: {:ok, Repo.get(Patient, id)} |> handle_nil()

defp handle_nil({:ok, nil}), do: {:error, :not_found}
defp handle_nil(result), do: result
```

---

## Testing Guidelines

### Unit Tests
- Test all context functions
- Test schema validations and changesets
- Use ExMachina for factories

### Property Tests
- Queue ordering must maintain triage + arrival invariant
- Status transitions must be valid

```elixir
property "queue always sorted by triage then arrival" do
  check all entries <- list_of(queue_entry_generator()) do
    sorted = Queues.sort_entries(entries)
    assert sorted == Enum.sort_by(entries, &{&1.triage_level, &1.checked_in_at})
  end
end
```

### Integration Tests
- Test LiveView user flows
- Test PubSub broadcasts
- Test Oban worker execution

---

## Deliverables Checklist

When generating code, ensure:
- [ ] Complete module with all functions
- [ ] Proper file path specified
- [ ] Types and specs included
- [ ] Validations comprehensive
- [ ] Error handling complete
- [ ] Tests included
- [ ] Documentation strings present

---

## Example Request Formats

**Schema Request:**
> "Generate the Room schema with status tracking"

**Context Request:**
> "Create the Queues context with add_to_queue and next_patient functions"

**LiveView Request:**
> "Build the Doctor Dashboard LiveView with next patient functionality"

**Migration Request:**
> "Create migration for queue_entries table with indexes"

**Test Request:**
> "Write property tests for queue ordering logic"
