defmodule Clinicflow.Repo.Migrations.CreateQueues do
  use Ecto.Migration

  def change do
    create table(:queues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :status, :string, default: "active", null: false

      timestamps(type: :utc_datetime)
    end

    create table(:queue_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :position, :integer, null: false
      add :triage_level, :string, default: "routine", null: false
      add :called_at, :utc_datetime
      add :removed_at, :utc_datetime
      add :queue_id, references(:queues, type: :binary_id, on_delete: :delete_all), null: false
      add :visit_id, references(:visits, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:queue_entries, [:queue_id])
    create index(:queue_entries, [:visit_id])
    create index(:queue_entries, [:triage_level])
    create unique_index(:queue_entries, [:queue_id, :visit_id], where: "removed_at IS NULL")
  end
end
