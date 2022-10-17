defmodule DnsPackets.Packets.Names do
  
  def decode_name(context) do
    # {rest, _, _ } = context
    # IO.puts "Decode name"
    # IO.inspect rest

    { name, context } = decode_name_parts(context, [])
    if String.length(name) > 1 && String.ends_with?(name, ".") do
      { String.slice(name, 0, String.length(name)-1), context}
    else
      { name, context }
    end
  end

  def decode_name_parts({<< 3 :: 2, name_offset :: 14, rest::binary>>, offset, segments}, result) do
    # IO.puts "Compressed #{name_offset}"
    cached = read_name_from_segments(name_offset, segments) 
    {
      (Enum.reverse(result) ++ cached) |> Enum.join("."),
      { rest, offset+2, segments }
    }
  end

  def decode_name_parts({<< 0 :: 8, rest::binary>>, offset, segments}, result) do
    {
      result |> Enum.reverse |> Enum.join("."), 
      { rest, offset+1, segments |> Map.put(offset, "") }
    }
  end

  def decode_name_parts({<< len :: 8, name :: binary-size(len), rest::binary>>, offset, segments}, results) do
    segments = segments |> Map.put(offset, name)
    decode_name_parts({rest, offset + len + 1, segments}, [ name | results ] )
  end

  def read_name_from_segments(offset, segments) do
    case Map.get(segments, offset, nil) do
      nil ->
        IO.puts "No segment at #{offset} in #{inspect segments}"
        [""]
      "" ->
        [""]  # end of list
      segment ->
        [ segment | read_name_from_segments(offset + String.length(segment) + 1, segments)]
    end
  end

end
