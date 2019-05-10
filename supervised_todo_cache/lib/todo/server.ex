defmodule Todo.Server do
  @moduledoc """
  GenServer for a Todo.List
  """

  use GenServer, restart: :temporary

  def start_link(name) do
    IO.puts("starting the todo list server")
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

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
  def init(name) do
    send(self(), :real_init)
    {:ok, name}
  end

  @impl GenServer
  def handle_info(:real_init, name) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list}
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    result = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, result)
    {:noreply, {name, result}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fun}, {name, todo_list}) do
    result = Todo.List.update_entry(todo_list, entry_id, update_fun)
    Todo.Database.store(name, result)
    {:noreply, {name, result}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    result = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, result)
    {:noreply, {name, result}}
  end
end

