defmodule Day_12_01 do
  import List

  def solve do 
    # input = File.read!("test.txt")
    input = File.read!("input.txt")
      |> String.strip()
      |> String.split("\n")
      |> Enum.map(fn pos_string -> String.split(pos_string, ",") end)
      |> Enum.map(fn pos_list -> Enum.map(pos_list, fn pos -> String.split(pos, "=") |> Enum.at(1) |> Integer.parse() |> elem(0) end) end)

    moons = init(input)

    moons
    |> apply_time_step(1000)
    |> get_energy()
  end

  def init([], [], payload), do: payload
  def init(positions, names \\ ["io", "europa", "ganymede", "callisto"], payload \\ %{}) do
    [name | names] = names
    [position | positions] = positions

    payload = Map.put(payload, String.to_atom(name), %{:position => position, :velocity => [0,0,0]})
    init(positions, names, payload)
  end

  def get_pairs(range, pairs \\ [], index \\ 0) do 
    range = Enum.to_list range
    rest = for x <- range, x !== index, do: {index, x}
    if (index + 1) == 4 do
      pairs
    else
      [_ | range] = range
      get_pairs(range, rest ++ pairs, index + 1)
    end
  end

  def apply_changes(a, b, index \\ 0, payload \\ []) do
    value_a = Enum.at(a, index)
    value_b = Enum.at(b, index)

    value = value_a + value_b

    if length(a) == index + 1 do
      payload ++ [value]
    else 
      apply_changes(a, b, index + 1, payload ++ [value])
    end 
  end 

  def compare(a, b, index \\ 0, payload \\ []) do
    value_a = Enum.at(a, index)
    value_b = Enum.at(b, index)

    value = cond do
      value_a > value_b ->
      -1
      value_a < value_b ->
      1
      true ->
      0
    end

    if length(a) == index + 1 do
      payload ++ [value]
    else 
      compare(a, b, index + 1, payload ++ [value])
    end
  end

  def apply_gravity(pair, moons) do
      key_a = pair |> Enum.at(0) |> String.to_atom()
      key_b = pair |> Enum.at(1) |> String.to_atom()

      moon_a = moons[key_a]
      moon_b = moons[key_b]

      new_velocity_a = compare(moon_a.position, moon_b.position)
      new_velocity_b = compare(moon_b.position, moon_a.position)

      moon_updated_a = Map.put(moon_a, :velocity, apply_changes(moon_a.velocity, new_velocity_a))
      moon_updated_b = Map.put(moon_b, :velocity, apply_changes(moon_b.velocity, new_velocity_b))

      moons = Map.put(moons, key_a, moon_updated_a)
      moons = Map.put(moons, key_b, moon_updated_b)
  end

  def apply_velocity(moon_name, moons) do
    moon_key = String.to_atom(moon_name)

    position = moons[moon_key].position
    velocity = moons[moon_key].velocity

    position = apply_changes(position, velocity)

    moons = Map.put(moons, moon_key, %{:position => position, :velocity => velocity})
  end

  def update_position(moons) do 
    names = ["io", "europa", "ganymede", "callisto"]
    combinations = get_pairs(0..3)
    all_pairs = Enum.map(combinations, fn combination -> 
      {index_a, index_b} = combination
      moon_a = Enum.at(names, index_a)
      moon_b = Enum.at(names, index_b)

      [moon_a, moon_b]
    end)
  
    moons = Enum.reduce(all_pairs, moons, &apply_gravity/2)
    moons = Enum.reduce(names, moons, &apply_velocity/2)
  end

  def apply_time_step(positions, max, index \\ 0) do
    positions = update_position(positions)

    if max == index + 1 do
      IO.puts "Timestep: #{index + 1}"
      positions
    else 
      IO.inspect positions
      apply_time_step(positions, max, index + 1)
    end
  end

  def get_energy(moons) do
    names = [:io, :europa, :ganymede, :callisto]
    energies = Enum.map(names, fn name -> 
      pot = moons[name].position |> Enum.reduce(0, fn (a, b) -> abs(a) + abs(b) end)
      kin = moons[name].velocity |> Enum.reduce(0, fn (a, b) -> abs(a) + abs(b) end)

      pot * kin
    end)

    Enum.reduce(energies, 0, fn (a, b) -> a + b end)
  end
end