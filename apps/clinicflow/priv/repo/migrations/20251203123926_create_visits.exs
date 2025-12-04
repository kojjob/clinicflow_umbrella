defmodule Clinicflow.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false, default: "waiting"
      add :reason, :string
      add :notes, :text
      add :checked_in_at, :utc_datetime, null: false
      add :started_at, :utc_datetime
      add :completed_at, :utc_datetime

      add :patient_id, references(:patients, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:patient_id])
    create index(:visits, [:status])
    create index(:visits, [:checked_in_at])
  end
end
