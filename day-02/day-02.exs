defmodule Day_02_01 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    input = replace_at(input, 1, 12)
    input = replace_at(input, 2, 2)

    IO.inspect input
    parse_input(input, 0)
  end

  def parse_input(integers, index) do
    current = Enum.at(integers, index)
    cond do
      current == 1 ->
        integers = addition(integers, index)
        parse_input(integers, index + 4)
      current == 2 ->
        integers = multiplication(integers, index)
        parse_input(integers, index + 4)
      current == 99 ->
        halt(integers)
      true ->
        IO.puts "unexpected op code"
    end
  end

  def addition(integers, index) do
    position1 = Enum.at(integers, index + 1)
    position2 = Enum.at(integers, index + 2)
    value1 = Enum.at(integers, position1)
    value2 = Enum.at(integers, position2)

    target = Enum.at(integers, index + 3)

    value = value1 + value2

    replace_at(integers, target, value)
  end

  def multiplication(integers, index) do
    position1 = Enum.at(integers, index + 1)
    position2 = Enum.at(integers, index + 2)
    value1 = Enum.at(integers, position1)
    value2 = Enum.at(integers, position2)

    target = Enum.at(integers, index + 3)

    value = value1 * value2

    replace_at(integers, target, value)
  end

  def halt(integers) do
    solution = first(integers)
    IO.puts "solution: #{solution}"
  end
end

defmodule Day_02_02 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    Enum.each(0..99, fn noun ->
      Enum.each(0..99, fn verb ->
        input = replace_at(input, 1, noun)
        input = replace_at(input, 2, verb)

        parse_input(input, 0)
      end)
    end)
  end

  def get_input do
    input = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    input = replace_at(input, 1, 12)
    input = replace_at(input, 2, 2)
  end

  def parse_input(integers, index) do
    current = Enum.at(integers, index)

    cond do
      current == 1 ->
        integers = addition(integers, index)
        parse_input(integers, index + 4)
      current == 2 ->
        integers = multiplication(integers, index)
        parse_input(integers, index + 4)
      current == 99 ->
        halt(integers, index)
      true ->
        IO.puts "unexpected op code"
    end
  end

  def addition(integers, index) do
    position1 = Enum.at(integers, index + 1)
    position2 = Enum.at(integers, index + 2)
    value1 = Enum.at(integers, position1)
    value2 = Enum.at(integers, position2)

    target = Enum.at(integers, index + 3)

    value = value1 + value2

    replace_at(integers, target, value)
  end

  def multiplication(integers, index) do
    position1 = Enum.at(integers, index + 1)
    position2 = Enum.at(integers, index + 2)
    value1 = Enum.at(integers, position1)
    value2 = Enum.at(integers, position2)

    target = Enum.at(integers, index + 3)

    value = value1 * value2

    replace_at(integers, target, value)
  end

  def halt(integers, index) do
    output = first(integers)

    noun = Enum.at(integers, 1)
    verb = Enum.at(integers, 2)

    if output == 19690720 do
      solution = 100 * noun + verb
      IO.puts "solution: #{solution}"
    end
  end
end
