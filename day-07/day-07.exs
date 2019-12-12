defmodule Day_07_01 do
  import List

  def solve do 
    program = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)
    
    elements = [0, 1, 2, 3, 4]
    all_combinations = for a <- elements, b <- elements, c <- elements, d <- elements, e <- elements, do: [a, b, c, d, e]
    combinations = Enum.filter(all_combinations, &has_no_duplicates/1)

    outputs = Enum.map(combinations, fn combination -> 
      output = get_output(combination, program)
    end)
    Enum.max(outputs)
  end

  def has_no_duplicates(list) do
    uniq_length = MapSet.size(MapSet.new(list))
    length(list) == uniq_length
  end

  def get_output(combination, program, index \\ 0, input \\ 0) do
      phase_code = Enum.at(combination, index)
      target = Enum.at(program, 1)
      modified_program = replace_at(program, target, phase_code)

      output = Intcode_computer.solve(modified_program, input)

      if length(combination) == index + 1 do
        output 
      else
        get_output(combination, program, index + 1, output)
      end
  end
end

defmodule Day_07_02 do
  import List

  def solve do 
    program = File.read!("input.txt")
    |> String.strip()
    |> String.split(",")
    |> Enum.map(fn n -> Integer.parse(n) |> elem(0) end)
    
    elements = [5, 6, 7, 8, 9]
    all_combinations = for a <- elements, b <- elements, c <- elements, d <- elements, e <- elements, do: [a, b, c, d, e]
    combinations = Enum.filter(all_combinations, &has_no_duplicates/1)

    outputs = Enum.map(combinations, fn combination -> 
      programs = Enum.map(combination, fn phase_code -> apply_phase_code(program, phase_code) end)
      starting_states = Enum.map(programs, fn program -> 
        %{:program => program, :pointer => 2, :output => 0}
      end)

      get_output(starting_states, 0)
    end)

    Enum.max(outputs)
  end

  def has_no_duplicates(list) do
    uniq_length = MapSet.size(MapSet.new(list))
    length(list) == uniq_length
  end

  def apply_phase_code(program, phase_code) do
    target = Enum.at(program, 1)
    modified_program = replace_at(program, target, phase_code)
  end

  def get_output(states, input_value, index \\ 0) do
    state = Enum.at(states, index)

    new_state = Intcode_computer.solve(state.program, input_value, state.pointer)
    # IO.inspect new_state
    if new_state == nil do 
      states |> Enum.map(fn state -> state.output end) |> Enum.max()
    else 
      states = replace_at(states, index, new_state)
      new_index = rem(index + 1, length(states));

      get_output(states, new_state.output, new_index)
    end
  end
end

defmodule Intcode_computer do
  import List

  def solve(program, value, index) do
    parse_input(program, value, index)
  end

  def parse_input(integers, value, index \\ 2) do
    current = Enum.at(integers, index)

    cond do 
      current == 99 ->
        halt(integers)
      current == 4 ->
        instructions = parse_instruction(current)

        op_code = instructions.op_code
        position_modes = instructions.position_modes

        output_value(integers, index, position_modes)
      true ->
        instructions = parse_instruction(current)

        op_code = instructions.op_code
        position_modes = instructions.position_modes

        integers = cond do
          op_code == 1 ->
            addition(integers, index, position_modes)
          op_code == 2 ->
            multiplication(integers, index, position_modes)
          op_code == 3 ->
            input_value(integers, index, value, position_modes)
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

        new_index = index + move_pointer
        parse_input(integers, value, new_index)
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

  def input_value(integers, index, value, position_modes) do
    target_mode = Enum.at(position_modes, index + 1)
    target = if target_mode == 1 do index + 1 else Enum.at(integers, index + 1) end

    replace_at(integers, target, value)
  end

  def output_value(integers, index, position_modes) do
    param = Enum.at(integers, index + 1)

    value = get_value(position_modes, 0).(integers, param)

    %{:program => integers, :pointer => index + 2, :output => value}
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
    nil
  end
end
