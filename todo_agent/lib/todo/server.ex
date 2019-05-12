defmodule Todo.Server do
  @moduledoc """
  Agent for a Todo.List
  """

  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        IO.puts("starting the todo list server")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  def add_entry(pid, new_entry) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        new_list = Todo.List.add_entry(todo_list, new_entry)
        Todo.Database.store(name, new_list)
        {name, new_list}
      end
    )
  end

  def entries(pid, date) do
    Agent.get(
      pid,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  def update_entry(pid, entry_id, update_fun) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        result = Todo.List.update_entry(todo_list, entry_id, update_fun)
        Todo.Database.store(name, result)
        {name, result}
      end
    )
  end

  def delete_entry(pid, entry_id) do
    Agent.cast(
      pid,
      fn {name, todo_list} ->
        result = Todo.List.delete_entry(todo_list, entry_id)
        Todo.Database.store(name, result)
        {name, result}
      end
    )
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end

