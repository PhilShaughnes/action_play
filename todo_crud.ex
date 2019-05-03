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


defmodule TodoList.CsvImporter do
  @doc ~S"""
  Imports the given file into a TodoList.

  ## Examples
  
    iex>  todo_list = TodoList.CsvImporter.import("todos.csv")
    
  """
  def import(file) do
    file
    |> File.stream!
    |> Enum.map(&extract_entry/1)
    |> TodoList.new
  end

  defp extract_entry(line) do
    [date, title] = parse_line(line)
    %{date: Date.from_iso8601!(date), title: title}
  end

  defp parse_line(line) do
    line
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.replace(&1, "/", "-"))
  end
end

defimpl String.Chars, for: TodoList do
  def to_string(todos) do
    "#TodoList"
  end
end
