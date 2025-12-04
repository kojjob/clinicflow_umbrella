defmodule Clinicflow.QueuesTest do
  use Clinicflow.DataCase, async: true

  alias Clinicflow.Queues
  alias Clinicflow.Queues.{Queue, QueueEntry}
  alias Clinicflow.Patients
  alias Clinicflow.Visits

  describe "queues" do
    @valid_attrs %{name: "Main Queue", status: :active}
    @update_attrs %{name: "Updated Queue"}
    @invalid_attrs %{name: nil}

    test "list_queues/0 returns all queues" do
      queue = queue_fixture()
      assert Queues.list_queues() == [queue]
    end

    test "get_queue!/1 returns the queue with given id" do
      queue = queue_fixture()
      assert Queues.get_queue!(queue.id) == queue
    end

    test "create_queue/1 with valid data creates a queue" do
      assert {:ok, %Queue{} = queue} = Queues.create_queue(@valid_attrs)
      assert queue.name == "Main Queue"
      assert queue.status == :active
    end

    test "create_queue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Queues.create_queue(@invalid_attrs)
    end

    test "update_queue/2 with valid data updates the queue" do
      queue = queue_fixture()
      assert {:ok, %Queue{} = updated} = Queues.update_queue(queue, @update_attrs)
      assert updated.name == "Updated Queue"
    end

    test "delete_queue/1 deletes the queue" do
      queue = queue_fixture()
      assert {:ok, %Queue{}} = Queues.delete_queue(queue)
      assert_raise Ecto.NoResultsError, fn -> Queues.get_queue!(queue.id) end
    end
  end

  describe "queue_entries" do
    setup do
      {:ok, patient} =
        Patients.create_patient(%{
          first_name: "Kofi",
          last_name: "Asante",
          phone: "+233244999888"
        })

      {:ok, visit} = Visits.create_visit(%{patient_id: patient.id, reason: "Checkup"})
      queue = queue_fixture()

      %{patient: patient, visit: visit, queue: queue}
    end

    test "add_to_queue/2 adds a visit to the queue", %{visit: visit, queue: queue} do
      assert {:ok, %QueueEntry{} = entry} =
               Queues.add_to_queue(queue, visit, :routine)

      assert entry.queue_id == queue.id
      assert entry.visit_id == visit.id
      assert entry.triage_level == :routine
      assert entry.position > 0
    end

    test "add_to_queue/2 assigns sequential positions", %{queue: queue} do
      entry1 = create_queue_entry(queue, :routine)
      entry2 = create_queue_entry(queue, :routine)
      entry3 = create_queue_entry(queue, :routine)

      assert entry2.position > entry1.position
      assert entry3.position > entry2.position
    end

    test "list_queue_entries/1 returns entries sorted by priority and position", %{queue: queue} do
      # Add in order: routine, urgent, emergency, routine
      routine1 = create_queue_entry(queue, :routine)
      urgent1 = create_queue_entry(queue, :urgent)
      emergency1 = create_queue_entry(queue, :emergency)
      routine2 = create_queue_entry(queue, :routine)

      entries = Queues.list_queue_entries(queue.id)
      entry_ids = Enum.map(entries, & &1.id)

      # Emergency first, then urgent, then routine by position
      assert entry_ids == [emergency1.id, urgent1.id, routine1.id, routine2.id]
    end

    test "get_queue_entry!/1 returns the entry", %{visit: visit, queue: queue} do
      {:ok, entry} = Queues.add_to_queue(queue, visit, :routine)
      assert Queues.get_queue_entry!(entry.id).id == entry.id
    end

    test "remove_from_queue/1 removes entry from queue", %{visit: visit, queue: queue} do
      {:ok, entry} = Queues.add_to_queue(queue, visit, :routine)
      assert {:ok, _} = Queues.remove_from_queue(entry)
      assert Queues.list_queue_entries(queue.id) == []
    end

    test "update_triage_level/2 changes triage level", %{visit: visit, queue: queue} do
      {:ok, entry} = Queues.add_to_queue(queue, visit, :routine)
      assert entry.triage_level == :routine

      assert {:ok, updated} = Queues.update_triage_level(entry, :urgent)
      assert updated.triage_level == :urgent
    end

    test "count_waiting/1 returns count of waiting patients", %{queue: queue} do
      _entry1 = create_queue_entry(queue, :routine)
      _entry2 = create_queue_entry(queue, :urgent)

      assert Queues.count_waiting(queue.id) == 2
    end

    test "get_next_patient/1 returns highest priority patient", %{queue: queue} do
      _routine = create_queue_entry(queue, :routine)
      _urgent = create_queue_entry(queue, :urgent)
      emergency = create_queue_entry(queue, :emergency)

      next = Queues.get_next_patient(queue.id)
      assert next.id == emergency.id
    end

    test "get_position/1 returns current position in queue", %{queue: queue} do
      entry1 = create_queue_entry(queue, :routine)
      _entry2 = create_queue_entry(queue, :routine)
      entry3 = create_queue_entry(queue, :routine)

      # All routine, so position based on arrival
      assert Queues.get_position(entry1) == 1
      assert Queues.get_position(entry3) == 3
    end

    test "get_position/1 accounts for triage priority", %{queue: queue} do
      routine1 = create_queue_entry(queue, :routine)
      _urgent1 = create_queue_entry(queue, :urgent)
      routine2 = create_queue_entry(queue, :routine)

      # Urgent patient jumps ahead, so routine1 is now at position 2
      assert Queues.get_position(routine1) == 2
      assert Queues.get_position(routine2) == 3
    end

    test "estimate_wait_time/1 calculates ETA based on position", %{queue: queue} do
      entry1 = create_queue_entry(queue, :routine)
      _entry2 = create_queue_entry(queue, :routine)
      entry3 = create_queue_entry(queue, :routine)

      # First patient should have lowest wait
      assert Queues.estimate_wait_time(entry1) < Queues.estimate_wait_time(entry3)
    end
  end

  # Helper functions
  defp queue_fixture(attrs \\ %{}) do
    {:ok, queue} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Queues.create_queue()

    queue
  end

  defp create_queue_entry(queue, triage_level) do
    {:ok, patient} =
      Patients.create_patient(%{
        first_name: "Patient#{System.unique_integer()}",
        last_name: "Test",
        phone:
          "+233244#{:rand.uniform(999_999) |> Integer.to_string() |> String.pad_leading(6, "0")}"
      })

    {:ok, visit} = Visits.create_visit(%{patient_id: patient.id})
    {:ok, entry} = Queues.add_to_queue(queue, visit, triage_level)
    entry
  end
end
