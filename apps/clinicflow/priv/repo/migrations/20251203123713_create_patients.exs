defmodule Clinicflow.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string, null: false
      add :email, :string
      add :date_of_birth, :date
      add :notification_preference, :string, default: "sms"
      add :opted_out_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:patients, [:phone])
    create index(:patients, [:last_name, :first_name])
  end
end
