defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @workers 3

  def start_link(_) do
    IO.puts("starting database pool")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key), do: GenServer.call(__MODULE__, {:choose_worker, key})

  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  def handle_call({:choose_worker, key}, _from, workers) do
    worker_key = :erlang.phash2(key, @workers)
    {:reply, Map.get(workers, worker_key), workers}
  end

  defp start_workers do
    for index <- 1..@workers, into: %{} do
      {:ok, worker_pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index - 1, worker_pid}
    end
  end
end
