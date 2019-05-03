defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &TodoList.add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry = %{id: old_entry_id}} ->
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end


defmodule TodoServer do
  use GenServer

  def start, do: GenServer.start(TodoServer, nil)

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, entry_id, updater_fun) do
    GenServer.cast(pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(_), do: {:ok, TodoList.new()}

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    {
      :reply,
      TodoList.entries(todo_list, date),
      todo_list
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    result = TodoList.add_entry(todo_list, entry)
    {:noreply, result}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fun}, todo_list) do
    result = TodoList.update_entry(todo_list, entry_id, update_fun)
    {:noreply, result}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    result = TodoList.delete_entry(todo_list, entry_id)
    {:noreply, result}
  end
end

