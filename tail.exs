defmodule Tail do
  def list_len([]), do: 0
  def list_len([_ | t]), do: 1 + list_len(t)

  def len(list), do: len(list, 0)
  defp len([], l), do: l
  defp len([_|t], l), do: len(t, l+1)


  def range(to, to), do: [to]
  def range(from, to) do
    [from | range(from+1, to)]
  end

  def rng(from, to), do: rng([], from, to)
  defp rng(list, from, from), do: [from | list]
  defp rng(list, from, to), do: rng([to | list], from, to-1)


  def positive([]), do: []
  def positive([h|t]) when h >= 0, do: [h | positive(t)]
  def positive([h|t]) when h < 0, do: positive(t)

  def pos(list), do: pos(list, [])
  defp pos([], result), do: Enum.reverse(result)
  defp pos([h|t], result) when h >= 0, do: pos(t, [h | result])
  defp pos([h|t], result) when h < 0, do: pos(t, result)
end
