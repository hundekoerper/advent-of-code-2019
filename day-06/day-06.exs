defmodule Day_06_01 do
  import List

  def solve do
    input =
      File.read!("input.txt")
      |> String.strip()
      |> String.split("\n")
      |> Enum.map(fn orbit -> String.split(orbit, ")") end)

    all_names =
      input
      |> Enum.reduce([], fn current, all -> [Enum.at(current, 0), Enum.at(current, 1)] ++ all end)
      |> Enum.uniq()

    planet_map =
      Enum.reduce(all_names, %{}, fn name, map ->
        key = String.to_atom(name)
        Map.put(map, key, init(name))
      end)

    planet_map = Enum.reduce(input, planet_map, &add_orbit/2)

    orbits =
      all_names
      |> Enum.map(fn name -> String.to_atom(name) end)
      |> Enum.map(fn name -> count_parents(planet_map, name) end)

    Enum.reduce(orbits, 0, fn count, sum -> count + sum end)
  end

  def init(name) do
    %{:name => name, :parent => nil, :children => []}
  end

  def add_orbit(insturction, map) do
    parent = Enum.at(insturction, 0) |> String.to_atom()
    child = Enum.at(insturction, 1) |> String.to_atom()

    new_parent = Map.put(map[parent], :children, [child] ++ map[parent].children)
    map = Map.put(map, parent, new_parent)

    new_child = Map.put(map[child], :parent, parent)
    map = Map.put(map, child, new_child)
  end

  def count_parents(map, name, count \\ 0) do
    parent = map[name].parent

    if parent == nil do
      count
    else
      count_parents(map, parent, count + 1)
    end
  end
end

defmodule Day_06_02 do
  import List

  def solve do
    input =
      File.read!("input.txt")
      |> String.strip()
      |> String.split("\n")
      |> Enum.map(fn orbit -> String.split(orbit, ")") end)

    all_names =
      input
      |> Enum.reduce([], fn current, all -> [Enum.at(current, 0), Enum.at(current, 1)] ++ all end)
      |> Enum.uniq()

    planet_map =
      Enum.reduce(all_names, %{}, fn name, map ->
        key = String.to_atom(name)
        Map.put(map, key, init(name))
      end)

    planet_map = Enum.reduce(input, planet_map, &add_orbit/2)

    count_transfers(planet_map, "YOU", "SAN")
  end

  def init(name) do
    %{:name => name, :parent => nil, :children => []}
  end

  def add_orbit(insturction, map) do
    parent = Enum.at(insturction, 0) |> String.to_atom()
    child = Enum.at(insturction, 1) |> String.to_atom()

    new_parent = Map.put(map[parent], :children, [child] ++ map[parent].children)
    IO.inspect new_parent
    map = Map.put(map, parent, new_parent)

    new_child = Map.put(map[child], :parent, parent)
    map = Map.put(map, child, new_child)
  end

  def count_transfers(map, a, b) do
    name_a = String.to_atom(a)
    name_b = String.to_atom(b)

    parents_a = get_parents(map, name_a)
    parents_b = get_parents(map, name_b)

    parents_temp = parents_a -- parents_b
    doubles = parents_a -- parents_temp

    (length(parents_a) - length(doubles)) + (length(parents_b) - length(doubles)) 
  end

  def get_parents(map, name, parents \\ []) do 
    parent = map[name].parent
    if parent == nil do
        parents
    else
        parents = [parent] ++ parents
        get_parents(map, parent, parents)
    end
  end
end
