defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{ color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{ image | pixel_map: pixel_map}
  end
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{ image | grid: grid}
  end

  @doc """
    Takes an image struct, pattern matches th hex values and
    --> passes to Enum.chunk_every >>> https://hexdocs.pm/elixir/1.13/Enum.html#chunk_every/2
    --> passes list of lists to Enum.map where we pass a reference to our mirror_row function
      NOTE: must pass a reference to the function because Elixir will automatically invoke a function
    --> flattens list of lists
    --> Enum.with_index >>> https://hexdocs.pm/elixir/1.13/Enum.html#with_index/2
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{ image | grid: grid}
  end

  @doc """
    Takes a row and adds the reverse of the first and second elements to the end of the list

    ## Example
      iex> Identicon.mirror_row([1,50,200])
      [1,50,200,50,1]
  """
  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end
  @doc """
    Takes an image struct, uses pattern matching to define r,g,b and discard tail/rest.
    Creates a new image struct taking all of the original image struct and additionally
    defining color to a tuple of r,g,b and returning

    ## Example
      iex> image = Identicon.hash_input("some word")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
        color: {214, 31, 218},
        grid: nil,
        hex: [214, 31, 218, 231, 11, 206, 22, 200, 50, 148, 162, 21, 51, 127, 122,122],
        pixel_map: nil
      }

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{ image | color: {r, g, b}}
  end
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
