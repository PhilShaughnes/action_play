defmodule Calculator do
  def value(server_pid) do
    send(server_pid, {:value, self()})
    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  def start, do: spawn(fn -> loop(0) end)

  # server implementation:

  defp loop(value) do
    new_value =
      receive do
        message -> process(value, message)
      end

    loop(new_value)
  end

  defp process(current_value, {:value, caller}), do: send(caller, {:response, current_value})

  defp process(current_value, {:add, value}), do: current_value + value
  defp process(current_value, {:sub, value}), do: current_value - value
  defp process(current_value, {:mul, value}), do: current_value * value
  defp process(current_value, {:div, value}), do: current_value / value

end
