defmodule Todo.Database do

  @db_folder Application.fetch_env!(:todo, :db_folder)
  @pool_size Application.fetch_env!(:todo, :db_pool_size)

  def child_spec(_) do
    # Node name is used to determine the database folder. This allows us to
    # start multiple nodes from the same folders, and data will not clash.
    [name_prefix, _] = "#{node()}" |> String.split("@")
    # db_folder = "#{Keyword.fetch!(db_settings, :folder)}/#{name_prefix}/"
    db_folder = "#{@db_folder}/#{name_prefix}/"

    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [db_folder]
    )
  end

  # defp worker_spec(worker_id) do
  #   default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
  #   Supervisor.child_spec(default_worker_spec, id: worker_id)
  # end

  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(key, data) do
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
