defmodule Day_05_01 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    parse_input(input)
  end

  def parse_input(integers, index \\ 0) do
    current = Enum.at(integers, index)
    instructions = parse_instruction(current)

    op_code = instructions.op_code
    position_modes = instructions.position_modes

    integers = cond do
      op_code == 1 ->
        addition(integers, index, position_modes)
      op_code == 2 ->
        multiplication(integers, index, position_modes)
      op_code == 3 ->
        input_value(integers, index, position_modes)
      op_code == 4 ->
        output_value(integers, index, position_modes)
      true ->
        IO.puts "unexpected op code"
    end

    unless op_code == 99 do
      new_index = index + instructions.move_pointer
      parse_input(integers, new_index)
    else
      halt(integers)
    end
  end

  def parse_instruction(integer) do
    instructions = integer
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    op_code = last(instructions)

    position_modes = instructions |> Enum.drop(-2) |> Enum.reverse()

    move_pointer = cond do
      op_code == 1 -> 4
      op_code == 2 -> 4
      op_code == 3 -> 2
      op_code == 4 -> 2
    end

    %{:op_code => op_code, :position_modes => position_modes, :move_pointer => move_pointer}
  end

  def get_value(modes, index) do
    mode = Enum.at(modes, index)
    if mode == 1 do
      fn (values, param) -> param end
    else
      fn (values, param) -> Enum.at(values, param) end
    end
  end

  def addition(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    mode1 = Enum.at(position_modes, 0)
    mode2 = Enum.at(position_modes, 1)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = value1 + value2

    integers = replace_at(integers, target, value)
  end

  def multiplication(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = value1 * value2

    replace_at(integers, target, value)
  end

  def input_value(integers, index, position_modes) do
    target_mode = Enum.at(position_modes, index + 1)
    target = if target_mode == 1 do index + 1 else Enum.at(integers, index + 1) end

    replace_at(integers, target, 1)
  end

  def output_value(integers, index, position_modes) do
    param = Enum.at(integers, index + 1)

    value = get_value(position_modes, 0).(integers, param)
    IO.puts "opcode 4: #{value}"

    integers
  end

  def halt(integers) do
    solution = first(integers)
    IO.puts "solution: #{solution}"
  end
end

defmodule Day_05_02 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    parse_input(input)
  end

  def parse_input(integers, index \\ 0) do
    current = Enum.at(integers, index)
    instructions = parse_instruction(current)

    op_code = instructions.op_code
    position_modes = instructions.position_modes

    integers = cond do
      op_code == 1 ->
        addition(integers, index, position_modes)
      op_code == 2 ->
        multiplication(integers, index, position_modes)
      op_code == 3 ->
        input_value(integers, index, position_modes)
      op_code == 4 ->
        output_value(integers, index, position_modes)
      op_code == 7 ->
        less_than(integers, index, position_modes)
      op_code == 8 ->
        equals(integers, index, position_modes)
      true ->
        integers
    end

    # :-(
    move_pointer = cond do
      op_code == 5 ->
        new_index = jump_if_true(integers, index, position_modes)
        if new_index == index, do: instructions.move_pointer, else: 0
      op_code == 6 ->
        new_index = jump_if_false(integers, index, position_modes)
        if new_index == index, do: instructions.move_pointer, else: 0
      true ->
        instructions.move_pointer
    end

    index = cond do
      op_code == 5 ->
        jump_if_true(integers, index, position_modes)
      op_code == 6 ->
        jump_if_false(integers, index, position_modes)
      true ->
        index
    end

    unless op_code == 99 do
      new_index = index + move_pointer
      parse_input(integers, new_index)
    else
      halt(integers)
    end
  end

  def parse_instruction(integer) do
    instructions = integer
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)

    op_code = last(instructions)

    position_modes = instructions |> Enum.drop(-2) |> Enum.reverse()

    move_pointer = cond do
      op_code == 1 -> 4
      op_code == 2 -> 4
      op_code == 3 -> 2
      op_code == 4 -> 2
      op_code == 5 -> 3
      op_code == 6 -> 3
      op_code == 7 -> 4
      op_code == 8 -> 4
    end

    %{:op_code => op_code, :position_modes => position_modes, :move_pointer => move_pointer}
  end

  def get_value(modes, index) do
    mode = Enum.at(modes, index)
    if mode == 1 do
      fn (values, param) -> param end
    else
      fn (values, param) -> Enum.at(values, param) end
    end
  end

  def addition(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    mode1 = Enum.at(position_modes, 0)
    mode2 = Enum.at(position_modes, 1)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = value1 + value2

    integers = replace_at(integers, target, value)
  end

  def multiplication(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = value1 * value2

    replace_at(integers, target, value)
  end

  def input_value(integers, index, position_modes) do
    target_mode = Enum.at(position_modes, index + 1)
    target = if target_mode == 1 do index + 1 else Enum.at(integers, index + 1) end

    replace_at(integers, target, 5)
  end

  def output_value(integers, index, position_modes) do
    param = Enum.at(integers, index + 1)

    value = get_value(position_modes, 0).(integers, param)
    IO.puts "opcode 4: #{value}"

    integers
  end

  def jump_if_true(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    if value1 != 0 do
      value2
    else
      index
    end
  end

  def jump_if_false(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    if value1 == 0 do
      value2
    else
      index
    end
  end

  def less_than(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = if value1 < value2, do: 1, else: 0

    replace_at(integers, target, value)
  end

  def equals(integers, index, position_modes) do
    param1 = Enum.at(integers, index + 1)
    param2 = Enum.at(integers, index + 2)

    value1 = get_value(position_modes, 0).(integers, param1)
    value2 = get_value(position_modes, 1).(integers, param2)

    target_mode = Enum.at(position_modes, index + 3)
    target = if target_mode == 1 do index + 3 else Enum.at(integers, index + 3) end

    value = if value1 == value2, do: 1, else: 0

    replace_at(integers, target, value)
  end

  def halt(integers) do
    solution = first(integers)
    IO.puts "solution: #{solution}"
  end
end
