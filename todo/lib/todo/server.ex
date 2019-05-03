defmodule Todo.Server do
  @moduledoc """
  GenServer for a Todo.List
  """

  use GenServer

  def start, do: GenServer.start(Todo.Server, nil)

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
  def init(_), do: {:ok, Todo.List.new()}

  @impl GenServer
  def handle_call({:entries, date}, _from, todo_list) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      todo_list
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    result = Todo.List.add_entry(todo_list, entry)
    {:noreply, result}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fun}, todo_list) do
    result = Todo.List.update_entry(todo_list, entry_id, update_fun)
    {:noreply, result}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    result = Todo.List.delete_entry(todo_list, entry_id)
    {:noreply, result}
  end
end

