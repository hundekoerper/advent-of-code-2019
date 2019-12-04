defmodule Day_04_01 do
  def solve do
    password = Enum.reduce(357253..892942, [], fn (number, passwords) ->
      input = number
      |> Integer.to_string()
      |> String.graphemes()

      has_double_char? = check_double_char?(input)
      is_increasing? = check_is_increasing?(input)

      if has_double_char? && is_increasing? do
        [input | passwords]
      else
        passwords
      end
    end)

    length(password)
  end

  def check_double_char?(string, index \\ 0) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)

    cond do
      length(string) == index + 1->
        false
      char == next_char ->
        true
      char != next_char ->
        check_double_char?(string, index + 1)
    end
  end

  def check_is_increasing?(string, index \\ 0) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)

    is_increasing? = char <= next_char

    cond do
      length(string) == (index + 1) ->
        true
      !is_increasing? ->
        false
      true ->
        check_is_increasing?(string, index + 1)
    end
  end
end

defmodule Day_04_02 do
  import List

  def solve do
    password = Enum.reduce(357253..892942, [], fn (number, passwords) ->
      input = number
      |> Integer.to_string()
      |> String.graphemes()

      has_double_char? = check_double_char?(input)
      is_increasing? = check_is_increasing?(input)

      if has_double_char? && is_increasing? do
        [input | passwords]
      else
        passwords
      end
    end)


    password = Enum.map(password, &(invalidate_tripples/1))

    password = Enum.reduce(password, [], fn (string, passwords) ->
      has_double_char? = check_double_char?(string)

      if has_double_char? do
        [string | passwords]
      else
        passwords
      end
    end)

    length(password)
  end

  def check_double_char?(string, index \\ 0) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)

    cond do
      length(string) == index + 1 ->
        false
      char == nil ->
        check_double_char?(string, index + 1)
      char == next_char ->
        true
      char != next_char ->
        check_double_char?(string, index + 1)
    end
  end

  def check_is_increasing?(string, index \\ 0) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)

    is_increasing? = char <= next_char

    cond do
      length(string) == (index + 1) ->
        true
      !is_increasing? ->
        false
      true ->
        check_is_increasing?(string, index + 1)
    end
  end

  def invalidate_tripples(string, index \\ 0) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)
    second_char = Enum.at(string, index + 2)

    cond do
      length(string) == index + 2 ->
        string
      char == next_char && char == second_char ->
        string = invalidate_char(string, index)
        invalidate_tripples(string, index + 1)
      true ->
        invalidate_tripples(string, index + 1)
    end
  end

  def invalidate_char(string, index) do
    char = Enum.at(string, index)
    next_char = Enum.at(string, index + 1)

    cond do
      length(string) == index + 1 ->
        string = replace_at(string, index, nil)
      char == next_char ->
        string = replace_at(string, index, nil)
        invalidate_char(string, index + 1)
      true ->
        string = replace_at(string, index, nil)
    end
  end
end
