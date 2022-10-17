defmodule DnsPackets.Packets do

  use Bitwise

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
    { header,      context }  = decode_header(context)
    { questions,   context }  = decode_questions(context, header.qd_count)
    { answers,     context }  = decode_answers(context, header.an_count)
    { authorities, context }  = decode_answers(context, header.ns_count)
    { additional,  _context } = decode_answers(context, header.ar_count)

    %__MODULE__{
      header:      header,
      questions:   questions,
      answers:     answers,
      authorities: authorities,
      additional:  additional,
    }
    # rescue _ ->
    #     bytes = rest |> :binary.bin_to_list |> Enum.map(&"0x#{Integer.to_string(&1, 16) |> String.pad_leading(2, "0")}")
    #     IO.puts(bytes |> Enum.join(", "))
    # end
  end

  @spec decode_header(parse_context) :: { Header.t, parse_context }
  def decode_header({ rest, offset, segments }) do
    { header, rest } = DnsPackets.Packets.Header.from_binary(rest)
    { header, { rest, offset+12, segments } }
  end


#  ╭──────────────────────────────────────────────────────────╮
#  │   Questions                                              │
#  ╰──────────────────────────────────────────────────────────╯

  @spec decode_questions(parse_context, integer) :: { [Question.t], parse_context }
  def decode_questions(context, count) do
    decode_questions(context, count, [])
  end

  def decode_questions({rest, offset, segments}, _count=0, result) do
    { result |> Enum.reverse, { rest, offset, segments }}
  end

  def decode_questions(context, count, result) do
    { query, context } = DnsPackets.Packets.Question.decode(context)
    decode_questions(context, count-1, [ query | result ])
  end


#  ╭──────────────────────────────────────────────────────────╮
#  │   Answer                                                 │
#  ╰──────────────────────────────────────────────────────────╯
  
  @spec decode_answers(parse_context, integer) :: { [Answer.t], parse_context }
  def decode_answers(context, count) do
    decode_answers(context, count, [])
  end

  @spec decode_answers(parse_context, integer, [ Answer.t ]) :: { [ Answer.t ], parse_context }
  def decode_answers(context, _count=0, result) do
    { result |> Enum.reverse, context}
  end

  def decode_answers(context, count, result) do
    { answer, context } = DnsPackets.Packets.Answer.decode(context)
    decode_answers(context, count-1, [ answer | result ])
  end


  # name
  
end
