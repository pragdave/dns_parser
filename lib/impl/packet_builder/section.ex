defmodule DnsPackets.PacketBuilder.Section do
  import Bitwise

  defstruct [ :original, :content, :base_offset, :offset]
  @type t :: %__MODULE__{ original: %{ String.t => integer }, content: [ binary ], base_offset: integer, offset: integer }

  @spec remove_content(t) :: t
  def remove_content(section) do
    %{ section | content: [] }
  end

  @spec bump_offset(t, integer) :: t
  def bump_offset(section, by) do
    %{ section | offset: section.offset + by }
  end

  @spec to_binary(t) :: binary
  def to_binary(section) do
    section.content |> Enum.reverse |> Enum.join()
  end

  def add_binary(section, extra \\ <<>>) do
    %{ 
      section | content: [ extra | section.content ]
    }
  end

  @spec add_single_string(t, String.t) :: t
  def add_single_string(section, string) do
    len = byte_size(string)
    bin = << len :: 8, string :: binary >>
    %{
      section | content: [ bin | section.content ], offset: section.offset + len + 1
    }
  end


  @spec add_name(t, String.t) :: t
  def add_name(section, string) do
      string 
      |> String.split(".")
      |> Enum.reduce(section, fn name, section ->
        add_string_fragment(section, name)
      end)
      |> add_terminator()
  end

  defp add_string_fragment(section, string) do
    original = section.original

    case Map.get(original, string) do
      nil ->
        original = 
          original 
          |> Map.put(string, << (section.base_offset + section.offset) ||| 0xc0 :: 16 >>)

        len = byte_size(string)
        encoded = << len :: 8, string :: binary >>
        %{ section 
          | original: original, 
          content: [ encoded | section.content ], 
          offset: section.offset + len + 1 }

      # don't compress a name in same section (like a.b.a) because
      # "a" will decompress to "a.b"
      pointer when pointer >= section.base_offset ->
        len = byte_size(string)
        encoded = << len :: 8, string :: binary >>
        %{ section |
          content: [ encoded | section.content ], 
          offset: section.offset + len + 1 }

      pointer ->
        %{ section | content: [ pointer | section.content ], offset: section.offset + 2}
    end
  end

  defp add_segment(string, offset, original) do
    original 
    |> Map.put(string, << (offset) ||| 0xc0 :: 16 >>)
  end

  defp add_terminator(section) do
    %{
      section |
      offset: section.offset + 1, 
      content: [ << 0 :: 8 >> | section.content],
      original: add_segment("", section.offset, section.original)
    }
  end
end


