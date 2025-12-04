defmodule Clinicflow.VisitsTest do
  use Clinicflow.DataCase, async: true

  alias Clinicflow.Visits
  alias Clinicflow.Visits.Visit
  alias Clinicflow.Patients

  describe "visits" do
    @patient_attrs %{
      first_name: "Ama",
      last_name: "Owusu",
      phone: "+233244111222"
    }

    @valid_attrs %{
      reason: "General checkup",
      notes: "Patient reports mild headache"
    }

    @update_attrs %{
      notes: "Updated notes after consultation"
    }

    @invalid_attrs %{patient_id: nil}

    setup do
      {:ok, patient} = Patients.create_patient(@patient_attrs)
      %{patient: patient}
    end

    test "list_visits/0 returns all visits", %{patient: patient} do
      visit = visit_fixture(patient)
      [returned_visit] = Visits.list_visits()
      assert returned_visit.id == visit.id
    end

    test "list_visits_for_patient/1 returns visits for a specific patient", %{patient: patient} do
      visit = visit_fixture(patient)
      {:ok, other_patient} = Patients.create_patient(%{@patient_attrs | phone: "+233244333444"})
      _other_visit = visit_fixture(other_patient)

      [returned_visit] = Visits.list_visits_for_patient(patient.id)
      assert returned_visit.id == visit.id
    end

    test "list_today_visits/0 returns only today's visits", %{patient: patient} do
      visit = visit_fixture(patient)
      [returned_visit] = Visits.list_today_visits()
      assert returned_visit.id == visit.id
    end

    test "get_visit!/1 returns the visit with given id", %{patient: patient} do
      visit = visit_fixture(patient)
      assert Visits.get_visit!(visit.id).id == visit.id
    end

    test "get_visit/1 returns the visit or nil", %{patient: patient} do
      visit = visit_fixture(patient)
      assert Visits.get_visit(visit.id).id == visit.id
      assert Visits.get_visit(Ecto.UUID.generate()) == nil
    end

    test "create_visit/1 with valid data creates a visit", %{patient: patient} do
      attrs = Map.put(@valid_attrs, :patient_id, patient.id)
      assert {:ok, %Visit{} = visit} = Visits.create_visit(attrs)
      assert visit.reason == "General checkup"
      assert visit.status == :waiting
      assert visit.patient_id == patient.id
      assert visit.checked_in_at != nil
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Visits.create_visit(@invalid_attrs)
    end

    test "create_visit/1 requires patient_id", %{patient: _patient} do
      assert {:error, changeset} = Visits.create_visit(@valid_attrs)
      assert "can't be blank" in errors_on(changeset).patient_id
    end

    test "update_visit/2 with valid data updates the visit", %{patient: patient} do
      visit = visit_fixture(patient)
      assert {:ok, %Visit{} = updated} = Visits.update_visit(visit, @update_attrs)
      assert updated.notes == "Updated notes after consultation"
    end

    test "delete_visit/1 deletes the visit", %{patient: patient} do
      visit = visit_fixture(patient)
      assert {:ok, %Visit{}} = Visits.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> Visits.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset", %{patient: patient} do
      visit = visit_fixture(patient)
      assert %Ecto.Changeset{} = Visits.change_visit(visit)
    end

    # Status transition tests
    test "start_consultation/1 transitions status to in_room", %{patient: patient} do
      visit = visit_fixture(patient)
      assert visit.status == :waiting

      assert {:ok, %Visit{} = started} = Visits.start_consultation(visit)
      assert started.status == :in_room
      assert started.started_at != nil
    end

    test "start_consultation/1 fails if not in waiting status", %{patient: patient} do
      visit = visit_fixture(patient)
      {:ok, started} = Visits.start_consultation(visit)

      assert {:error, changeset} = Visits.start_consultation(started)
      assert "must be waiting to start consultation" in errors_on(changeset).status
    end

    test "complete_visit/1 transitions status to done", %{patient: patient} do
      visit = visit_fixture(patient)
      {:ok, started} = Visits.start_consultation(visit)

      assert {:ok, %Visit{} = completed} = Visits.complete_visit(started)
      assert completed.status == :done
      assert completed.completed_at != nil
    end

    test "complete_visit/1 fails if not in in_room status", %{patient: patient} do
      visit = visit_fixture(patient)

      assert {:error, changeset} = Visits.complete_visit(visit)
      assert "must be in room to complete visit" in errors_on(changeset).status
    end

    test "mark_no_show/1 marks patient as no-show", %{patient: patient} do
      visit = visit_fixture(patient)

      assert {:ok, %Visit{} = no_show} = Visits.mark_no_show(visit)
      assert no_show.status == :no_show
    end

    test "mark_no_show/1 fails if not in waiting status", %{patient: patient} do
      visit = visit_fixture(patient)
      {:ok, started} = Visits.start_consultation(visit)

      assert {:error, changeset} = Visits.mark_no_show(started)
      assert "must be waiting to mark as no-show" in errors_on(changeset).status
    end

    # Duration calculation tests
    test "get_wait_duration/1 calculates wait time in minutes", %{patient: patient} do
      visit = visit_fixture(patient)
      # Just created, should be ~0 minutes
      assert Visits.get_wait_duration(visit) >= 0
    end

    test "get_consultation_duration/1 returns nil if not started", %{patient: patient} do
      visit = visit_fixture(patient)
      assert Visits.get_consultation_duration(visit) == nil
    end
  end

  defp visit_fixture(patient, attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Map.put(:patient_id, patient.id)
      |> Visits.create_visit()

    visit
  end
end
