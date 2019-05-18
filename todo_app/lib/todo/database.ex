defmodule Todo.Database do

  @db_folder "./persist"
  @pool_size 3

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  # defp worker_spec(worker_id) do
  #   default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
  #   Supervisor.child_spec(default_worker_spec, id: worker_id)
  # end

  def store(key, data) do
    # key
    # |> choose_worker()
    # |> Todo.DatabaseWorker.store(key, data)

    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )

  end

  def get(key) do
    # key
    # |> choose_worker()
    # |> Todo.DatabaseWorker.get(key)

    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  # defp choose_worker(key), do: :erlang.phash2(key, @pool_size) + 1
end
