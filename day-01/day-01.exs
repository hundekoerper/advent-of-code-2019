defmodule Day_01_01 do
  import Enum

  def solve do
    input = File.stream!("input.txt")
    |> Stream.map(&String.trim_trailing/1)
    |> to_list
    |> map(fn n -> Integer.parse(n) |> elem(0) end)
    |> map(&calculate_fuel/1)

    sum_list(input, 0)
  end

  def calculate_fuel(mass) do
    mass
    |> Kernel./(3)
    |> Float.floor()
    |> Kernel.-(2)
  end

  def sum_list([], acc), do: acc
  def sum_list(list, acc) do
    [value | remaining] = list
    acc = acc + value
    sum_list(remaining, acc)
  end

end

defmodule Day_01_02 do
  import Enum

  def solve do
    # input = File.stream!("test.txt")
    input = File.stream!("input.txt")
    |> Stream.map(&String.trim_trailing/1)
    |> to_list
    |> map(fn n -> Integer.parse(n) |> elem(0) end)
    |> map(fn input -> calculate_extra_fuel(input, input) - input end)

    Day_01_01.sum_list(input, 0)
  end

  defp calculate_extra_fuel(extra, total) when extra <= 0, do: total
  defp calculate_extra_fuel(extra, total) do
    extra = Day_01_01.calculate_fuel(extra)
    unless extra <= 0 do
      calculate_extra_fuel(extra, total + extra)
    else
      calculate_extra_fuel(extra, total)
    end
  end
end
