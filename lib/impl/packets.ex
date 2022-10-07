
# indirection mask for compressed domain names
# defmodule X do
#   @compile {:inline, indir_mask: 0}
#   def indir_mask, do: 0xC0
# end

defmodule Question do
  defstruct [ :name, :qtype, :qclass  ]
  @type t :: %__MODULE__{name: String.t, qtype: Packet.T.t, qclass: Packet.C.t }
end

defmodule Answer do 
  defstruct [ :name, :atype, :aclass, :ttl, :rdata ]
  @type t :: %__MODULE__{
    name: String.t, atype: Packet.T.t, aclass: Packet.C.t,
    ttl: integer(), rdata: binary
  }
end

defmodule Header do
  defstruct [
   :id, :qr, :opcode, :aa, :tc, :rd, :ra, :pr, :rcode,
    :qd_count, :an_count, :ns_count, :ar_count,
  ]

  @type t :: %__MODULE__{ 
  id: integer(),
   qr: boolean,
   opcode: Packer.Opcode.t,
   aa: boolean,
   tc: boolean,
   rd: boolean,
   ra: boolean,
   pr: boolean,
   rcode: Packet.RC.t,
   qd_count: integer(),
   an_count: integer(),
   ns_count: integer(),
   ar_count: integer(),
  }
end

defmodule Packet do

  @type t :: %__MODULE__{
    header:      Header.t,
    questions:   [ Question.t ],
    answers:     [ Answer.t ],
    authorities: [ Answer.t ],
    additional:  [ Answer.t ]
  }

  defstruct [ :header, :questions, :answers, :authorities, :additional ]


  @type parse_context :: { rest :: binary, offset :: integer(), segments :: Map.t  }

  @spec decode_packet(binary) :: t
  def decode_packet(rest) do
    context = { rest, 0, Map.new() }
    { header, context } = decode_header(context)
    { questions, context } = decode_questions(context, header.qd_count)
    { answers, context } = decode_answers(context, header.an_count)
    { authorities, context } = decode_answers(context, header.ns_count)
    { additional, _context } = decode_answers(context, header.ar_count)

    %__MODULE__{
      header: header,
      questions: questions,
      answers: answers,
      authorities: authorities,
      additional: additional,
    }
  end

  @spec decode_header(parse_context) :: { Header.t, parse_context }
  defp decode_header({<<
    id :: 16, qr :: 1, opcode :: 4, aa :: 1, tc :: 1, rd :: 1, 
    ra :: 1, pr :: 1,
    _unused :: 2,
    rcode :: 4, qd_count :: 16, an_count :: 16, ns_count :: 16, ar_count :: 16,
    rest :: binary
    >>,
    offset, segments
  }) do

    header = %Header{
      id: id,
      qr: qr != 0,
      opcode: opcode,
      aa: aa != 0,
      tc: tc != 0,
      rd: rd != 0,
      ra: ra != 0,
      pr: pr != 0,
      rcode: rcode,
      qd_count: qd_count,
      an_count: an_count,
      ns_count: ns_count,
      ar_count: ar_count,
    }

    { header, { rest, offset+12, segments } }
  end


  # Questions

  @spec decode_questions(parse_context, integer) :: { [Question.t], parse_context }
  defp decode_questions(context, count) do
    decode_questions(context, count, [])
  end

  defp decode_questions({rest, offset, segments}, _count=0, result) do
    { result |> Enum.reverse, { rest, offset, segments }}
  end

  defp decode_questions(context, count, result) do
    { query, context } = decode_query(context)
    decode_questions(context, count-1, [ query | result ])
  end

  defp decode_query(context) do
    { name, {rest, offset, segments} } = decode_name(context)
    << qtype :: 16, qclass :: 16, rest :: binary >> = rest
    result = %Question{ name: name, qtype: qtype, qclass: qclass }
    { result, { rest, offset + 4, segments }}
  end

  # Answer
  
  @spec decode_answers(parse_context, integer) :: { [Answer.t], parse_context }
  defp decode_answers(context, count) do
    decode_answers(context, count, [])
  end

  @spec decode_answers(parse_context, integer, [ Answer.t ]) :: { [ Answer.t ], parse_context }
  defp decode_answers(context, _count=0, result) do
    { result |> Enum.reverse, context}
  end

  defp decode_answers(context, count, result) do
    { answer, context } = decode_answer(context)
    decode_answers(context, count-1, [ answer | result ])
  end

  defp decode_answer(context) do
    { name, {rest, offset, segments} } = decode_name(context)
    << atype :: 16, aclass :: 16, ttl :: 32,
      _rdlength :: 16, rest :: binary >> = rest

    { rdata, context } = RR.decode({ rest, offset+10, segments }, atype)
    
    result = %Answer{
      name: name, atype: atype, aclass: aclass,
      ttl: ttl, rdata: rdata,
    }
    { result, context}
  end


  # name
  
  def decode_name(context) do
    { name, context } = decode_name_parts(context, [])
    if String.length(name) > 1 && String.ends_with?(name, ".") do
      { String.slice(name, 0, String.length(name)-1), context}
    else
      { name, context }
    end
  end

  defp decode_name_parts({<< 3 :: 2, name_offset :: 14, rest::binary>>, offset, segments}, result) do
    cached = read_name_from_segments(name_offset, segments) 
    {
      (Enum.reverse(result) ++ cached) |> Enum.join("."),
      { rest, offset+1, segments }
    }
  end

  defp decode_name_parts({<< 0 :: 8, rest::binary>>, offset, segments}, result) do
    {
      result |> Enum.reverse |> Enum.join("."), 
      { rest, offset+1, segments |> Map.put(offset, "") }
    }
  end

  defp decode_name_parts({<< len :: 8, name :: binary-size(len), rest::binary>>, offset, segments}, results) do
    segments = segments |> Map.put(offset, name)
    decode_name_parts({rest, offset + len + 1, segments}, [ name | results ] )
  end

  defp read_name_from_segments(offset, segments) do
    segment = Map.get(segments, offset, "")

    if segment == "" do
      [""]
    else
      [ segment | read_name_from_segments(offset + String.length(segment) + 1, segments)]
    end
  end

end
