defmodule Todo.DatabaseWorker do
    use GenServer

  def start_link(db_folder) do
    IO.puts("starting db worker")

    GenServer.start_link(
      __MODULE__,
      db_folder
    )
  end

  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(db_folder) do
    {:ok, db_folder}
  end

  def handle_call({:store, key, data}, _from, db_folder) do
    file_persist(key, db_folder, data)
    {:reply, :ok, db_folder}
  end

  def handle_call({:get, key}, _from, db_folder) do
    {:reply, file_read(key, db_folder), db_folder}
  end

  defp file_persist(key, db_folder, data) do
    key
    |> file_name(db_folder)
    |> File.write!(:erlang.term_to_binary(data))
  end

  defp file_read(key, db_folder) do
    case File.read(file_name(key, db_folder)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      {:error, :enoent} -> nil
    end
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end
end
