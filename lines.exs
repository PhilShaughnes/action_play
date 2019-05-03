defmodule Lines do
  def lines_lengths!(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.length/1)
  end

  def longest_line_length!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.length/1)
    |> Enum.max
  end

  def longest_line!(path) do
    path
    |> File.stream!()
    |> Enum.max_by(&String.length/0)
  end

  def words_per_line!(path) do
    path
    |> File.stream!
    |> Enum.map(&word_count/1)
  end

  def word_count(string) do
    string
    |> String.split
    |> length
  end

end

