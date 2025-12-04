defmodule Clinicflow.PatientsTest do
  use Clinicflow.DataCase, async: true

  alias Clinicflow.Patients
  alias Clinicflow.Patients.Patient

  describe "patients" do
    @valid_attrs %{
      first_name: "Kwame",
      last_name: "Asante",
      phone: "+233244123456",
      email: "kwame@example.com",
      date_of_birth: ~D[1990-05-15]
    }

    @update_attrs %{
      first_name: "Kofi",
      last_name: "Mensah",
      phone: "+233244654321"
    }

    @invalid_attrs %{first_name: nil, last_name: nil, phone: nil}

    test "list_patients/0 returns all patients" do
      patient = patient_fixture()
      assert Patients.list_patients() == [patient]
    end

    test "get_patient!/1 returns the patient with given id" do
      patient = patient_fixture()
      assert Patients.get_patient!(patient.id) == patient
    end

    test "get_patient/1 returns the patient or nil" do
      patient = patient_fixture()
      assert Patients.get_patient(patient.id) == patient
      assert Patients.get_patient(Ecto.UUID.generate()) == nil
    end

    test "create_patient/1 with valid data creates a patient" do
      assert {:ok, %Patient{} = patient} = Patients.create_patient(@valid_attrs)
      assert patient.first_name == "Kwame"
      assert patient.last_name == "Asante"
      assert patient.phone == "+233244123456"
      assert patient.email == "kwame@example.com"
      assert patient.date_of_birth == ~D[1990-05-15]
    end

    test "create_patient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Patients.create_patient(@invalid_attrs)
    end

    test "create_patient/1 requires first_name" do
      attrs = Map.delete(@valid_attrs, :first_name)
      assert {:error, changeset} = Patients.create_patient(attrs)
      assert "can't be blank" in errors_on(changeset).first_name
    end

    test "create_patient/1 requires last_name" do
      attrs = Map.delete(@valid_attrs, :last_name)
      assert {:error, changeset} = Patients.create_patient(attrs)
      assert "can't be blank" in errors_on(changeset).last_name
    end

    test "create_patient/1 requires phone" do
      attrs = Map.delete(@valid_attrs, :phone)
      assert {:error, changeset} = Patients.create_patient(attrs)
      assert "can't be blank" in errors_on(changeset).phone
    end

    test "create_patient/1 validates phone format" do
      attrs = Map.put(@valid_attrs, :phone, "invalid")
      assert {:error, changeset} = Patients.create_patient(attrs)
      assert "must be a valid phone number" in errors_on(changeset).phone
    end

    test "create_patient/1 validates email format when provided" do
      attrs = Map.put(@valid_attrs, :email, "invalid-email")
      assert {:error, changeset} = Patients.create_patient(attrs)
      assert "must be a valid email" in errors_on(changeset).email
    end

    test "create_patient/1 allows nil email" do
      attrs = Map.delete(@valid_attrs, :email)
      assert {:ok, %Patient{email: nil}} = Patients.create_patient(attrs)
    end

    test "update_patient/2 with valid data updates the patient" do
      patient = patient_fixture()
      assert {:ok, %Patient{} = updated} = Patients.update_patient(patient, @update_attrs)
      assert updated.first_name == "Kofi"
      assert updated.last_name == "Mensah"
      assert updated.phone == "+233244654321"
    end

    test "update_patient/2 with invalid data returns error changeset" do
      patient = patient_fixture()
      assert {:error, %Ecto.Changeset{}} = Patients.update_patient(patient, @invalid_attrs)
      assert patient == Patients.get_patient!(patient.id)
    end

    test "delete_patient/1 deletes the patient" do
      patient = patient_fixture()
      assert {:ok, %Patient{}} = Patients.delete_patient(patient)
      assert_raise Ecto.NoResultsError, fn -> Patients.get_patient!(patient.id) end
    end

    test "change_patient/1 returns a patient changeset" do
      patient = patient_fixture()
      assert %Ecto.Changeset{} = Patients.change_patient(patient)
    end

    test "search_patients/1 finds patients by name" do
      patient = patient_fixture()
      assert [found] = Patients.search_patients("Kwame")
      assert found.id == patient.id
    end

    test "search_patients/1 finds patients by phone" do
      patient = patient_fixture()
      assert [found] = Patients.search_patients("+233244123456")
      assert found.id == patient.id
    end

    test "search_patients/1 returns empty list when no match" do
      _patient = patient_fixture()
      assert [] = Patients.search_patients("nonexistent")
    end

    test "get_display_name/1 returns anonymized name" do
      patient = patient_fixture()
      assert Patients.get_display_name(patient) == "Kwame A."
    end
  end

  defp patient_fixture(attrs \\ %{}) do
    {:ok, patient} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Patients.create_patient()

    patient
  end
end
