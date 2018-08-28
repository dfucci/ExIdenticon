defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello
      :world

  """
  def main(input) do
    input 
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd
    |> pixel_map
    |> draw
    |> save(input) 
  end

  def save(image, input) do
   File.write("#{input}.png", image) 
  end

  def draw(%Identicon.Image{color: color, pixel_map: pixel_map}) do
   image = :egd.create(250, 250) 
   fill = :egd.color(color)
   Enum.each pixel_map, fn({start, stop}) ->
    :egd.filledRectangle(image, start, stop, fill)
   end
   
   :egd.render(image)
  end

  def pixel_map(%Identicon.Image{grid: grid} = image) do
   pixel_map = Enum.map grid, fn({_, index}) -> 
    h = rem(index, 5) * 50
    v = div(index, 5) * 50

    top_left = {h, v}
    bottom_right = {h + 50, v + 50}
    {top_left, bottom_right}
   end 

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid = hex_list
    |> Enum.chunk(3) 
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def filter_odd(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _}) -> rem(code, 2) == 0 end

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _] = row
    row ++ [second, first]
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
   hex = :crypto.hash(:md5, input)
   |> :binary.bin_to_list 
   %Identicon.Image{hex: hex}
  end
end
