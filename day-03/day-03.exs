defmodule Day_03_01 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(fn str -> String.split(str, ",") end)

    input = Enum.drop(input, -1)
    input = Enum.map(input, fn wire -> Enum.map(wire, &(parse_value/1)) end)

    wire_1 = Enum.at(input, 0)
    wire_2 = Enum.at(input, 1)

    positions_1 = get_positions(wire_1)
    positions_2 = get_positions(wire_2)

    positions_temp = positions_2 -- positions_1
    intersections = positions_2 -- positions_temp

    intersections = Enum.drop(intersections, -1)
    distances = Enum.map(intersections, &(get_distance/1))

    Enum.min(distances)
  end

  def parse_value(str) do
    direction = String.at(str, 0)
    value = String.slice(str, 1..-1) |> Integer.parse() |> elem(0)

    {direction, value}
  end

  def get_positions(instructions) do
    Enum.reduce(instructions, [{1,1}], fn (instruction, positions) ->
      last_position = first(positions)
      last_x = elem(last_position, 0)
      last_y = elem(last_position, 1)

      direction = elem(instruction, 0)
      value = elem(instruction, 1)

      new_position = last_position

      cond do
        direction == "U" ->
          new_positions = Enum.map((last_y + value)..last_y + 1, fn y ->
            {last_x, y}
          end)
          new_positions ++ positions
        direction == "D" ->
          new_positions = Enum.map((last_y - value)..last_y - 1, fn y ->
            {last_x, y}
          end)
          new_positions ++ positions
        direction == "R" ->
          new_positions = Enum.map((last_x + value)..last_x + 1, fn x ->
            {x, last_y}
          end)
          new_positions ++ positions
        direction == "L" ->
          new_positions = Enum.map((last_x - value)..last_x - 1, fn x ->
            {x, last_y}
          end)
          new_positions ++ positions
      end
    end)
  end

  def get_distance(position) do
    start_x = 1
    start_y = 1

    x = elem(position, 0)
    y = elem(position, 1)

    abs(start_x - x) + abs(start_y - y)
  end
end

defmodule Day_03_02 do
  import List

  def solve do
    input = File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(fn str -> String.split(str, ",") end)

    input = Enum.drop(input, -1)
    input = Enum.map(input, fn wire -> Enum.map(wire, &(parse_value/1)) end)

    wire_1 = Enum.at(input, 0)
    wire_2 = Enum.at(input, 1)

    positions_1 = get_positions(wire_1)
    positions_2 = get_positions(wire_2)

    intersections = get_intersections(positions_1, positions_2)
    intersections = Enum.drop(intersections, -1)

    step_sums = get_step_sums(intersections, positions_1, positions_2)
    Enum.min(step_sums)
  end

  def parse_value(str) do
    direction = String.at(str, 0)
    value = String.slice(str, 1..-1) |> Integer.parse() |> elem(0)

    {direction, value}
  end

  def get_intersections(a, b) do
    a_positions = Enum.map(a, fn point -> point.position end)
    b_positions = Enum.map(b, fn point -> point.position end)

    positions_temp = b_positions -- a_positions

    b_positions -- positions_temp
  end

  def get_positions(instructions) do
    start = %{:steps => 0, :position => {1,1}}
    Enum.reduce(instructions, [start], fn (instruction, positions) ->
      last_position = first(positions)

      last_value = last_position.steps
      last_x = elem(last_position.position, 0)
      last_y = elem(last_position.position, 1)

      direction = elem(instruction, 0)
      value = elem(instruction, 1)

      new_position = last_position

      cond do
        direction == "U" ->
          new_positions = Enum.map((last_y + 1)..last_y + value, fn y ->
            step_value = y - last_y
            %{:steps => last_value + step_value, :position => {last_x, y}}
          end)
          new_positions = Enum.reverse(new_positions)
          new_positions ++ positions
        direction == "D" ->
          new_positions = Enum.map((last_y - 1)..last_y - value, fn y ->
            step_value = last_y - y
            %{:steps => last_value + step_value, :position => {last_x, y}}
          end)
          new_positions = Enum.reverse(new_positions)
          new_positions ++ positions
        direction == "R" ->
          new_positions = Enum.map((last_x + 1)..last_x + value, fn x ->
            step_value = x - last_x
            %{:steps => last_value + step_value, :position =>  {x, last_y}}
          end)
          new_positions = Enum.reverse(new_positions)
          new_positions ++ positions
        direction == "L" ->
          new_positions = Enum.map((last_x - 1)..last_x - value, fn x ->
            step_value = last_x - x
            %{:steps => last_value + step_value, :position =>  {x, last_y}}
          end)
          new_positions = Enum.reverse(new_positions)
          new_positions ++ positions
      end
    end)
  end

  def get_step_sums(intersections, a, b) do
    Enum.map(intersections, fn intersection ->
      point_a = Enum.find(a, fn point ->
        point.position == intersection
      end)

      point_b = Enum.find(b, fn point ->
        point.position == intersection
      end)

      sum = point_a.steps + point_b.steps
    end)
  end
end
