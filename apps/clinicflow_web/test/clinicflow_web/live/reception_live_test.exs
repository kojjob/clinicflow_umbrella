defmodule ClinicflowWeb.ReceptionLiveTest do
  use ClinicflowWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Clinicflow.Patients
  alias Clinicflow.Visits
  alias Clinicflow.Queues

  describe "Reception Queue Dashboard" do
    test "renders the reception queue page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/reception")

      assert html =~ "Reception Queue"
      assert html =~ "Add Patient"
    end

    test "displays stat cards", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/reception")

      assert html =~ "Total Waiting"
      assert html =~ "Emergency"
      assert html =~ "Urgent"
      assert html =~ "Avg Wait"
    end

    test "shows empty state when no patients in queue", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/reception")

      assert html =~ "No patients in queue"
    end

    test "opens add patient panel when clicking add button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reception")

      # Click the add patient button (using ID)
      html = view |> element("button[phx-click=open_add_patient]") |> render_click()

      assert html =~ "Add Patient to Queue"
      assert html =~ "Search Existing Patient"
      assert html =~ "Or create new patient"
    end

    test "closes add patient panel via X button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reception")

      # Open the panel
      html = view |> element("button[phx-click=open_add_patient]") |> render_click()

      # Panel should be visible with the form
      assert html =~ "Add Patient to Queue"

      # Close via close button click (using the actual event name from LiveView)
      html = view |> render_click("close_modal")

      # Panel content should no longer be visible
      refute html =~ "Add Patient to Queue"
    end

    test "displays patients in queue", %{conn: conn} do
      # Create a patient and add to queue
      {:ok, patient} =
        Patients.create_patient(%{
          first_name: "John",
          last_name: "Doe",
          phone: "+233123456789"
        })

      {:ok, visit} =
        Visits.create_visit(%{
          patient_id: patient.id,
          reason: "Checkup"
        })

      # Get or create a queue
      queue =
        case Queues.list_queues() do
          [q | _] ->
            q

          [] ->
            {:ok, q} = Queues.create_queue(%{name: "Main Queue", status: :active})
            q
        end

      {:ok, _entry} = Queues.add_to_queue(queue, visit, :urgent)

      {:ok, _view, html} = live(conn, ~p"/reception")

      # Should display the patient
      assert html =~ "John D."
      assert html =~ "Urgent"
      assert html =~ "Checkup"
    end

    test "can search for patients", %{conn: conn} do
      # Create a patient
      {:ok, _patient} =
        Patients.create_patient(%{
          first_name: "Jane",
          last_name: "Smith",
          phone: "+233987654321"
        })

      {:ok, view, _html} = live(conn, ~p"/reception")

      # Open the panel
      view |> element("button[phx-click=open_add_patient]") |> render_click()

      # Search for the patient
      html =
        view |> element("input[phx-keyup=search_patient]") |> render_keyup(%{"value" => "Jane"})

      assert html =~ "Jane Smith"
    end

    test "can call patient from queue", %{conn: conn} do
      # Create a patient and add to queue
      {:ok, patient} =
        Patients.create_patient(%{
          first_name: "Bob",
          last_name: "Builder",
          phone: "+233444555666"
        })

      {:ok, visit} =
        Visits.create_visit(%{
          patient_id: patient.id,
          reason: "Follow-up"
        })

      queue =
        case Queues.list_queues() do
          [q | _] ->
            q

          [] ->
            {:ok, q} = Queues.create_queue(%{name: "Main Queue", status: :active})
            q
        end

      {:ok, entry} = Queues.add_to_queue(queue, visit, :routine)

      {:ok, view, _html} = live(conn, ~p"/reception")

      # Click the call button using render_click with event name and value
      html = view |> render_click("call_patient", %{"id" => entry.id})

      assert html =~ "Calling Bob B."
    end

    test "can remove patient from queue", %{conn: conn} do
      # Create a patient and add to queue
      {:ok, patient} =
        Patients.create_patient(%{
          first_name: "Carol",
          last_name: "Dancer",
          phone: "+233777888999"
        })

      {:ok, visit} =
        Visits.create_visit(%{
          patient_id: patient.id,
          reason: "Test"
        })

      queue =
        case Queues.list_queues() do
          [q | _] ->
            q

          [] ->
            {:ok, q} = Queues.create_queue(%{name: "Main Queue", status: :active})
            q
        end

      {:ok, entry} = Queues.add_to_queue(queue, visit, :routine)

      {:ok, view, _html} = live(conn, ~p"/reception")

      # Click the remove button using render_click with event name and value
      html = view |> render_click("remove_patient", %{"id" => entry.id})

      assert html =~ "Patient removed from queue"
    end
  end
end
