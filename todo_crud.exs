defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries // []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
    %TodoList{}
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    entries
  end
end

defmodule Entry do
  defstruct date: today(), title: nil

  def today() do
    :calendar.local_time()
    |> erl_date
    |> Date.from_erl!
  end

  defp erl_date({date, _time}), do: date
end


# defmodule MultiDict do
#   def new(), do: %{}

#   def add(dict, key, value) do
#     Map.update(dict, key, [value], &[value | &1])
#   end

#   def get(dict, key) do
#     Map.get(dict, key, [])
#   end
# end
