defmodule DnsPackets.PacketBuilder do
  defstruct [ :sections, :offset, :segments, :now ]
  alias DnsPackets.PacketBuilder.Section, as: PBS
  alias DnsPackets.Packets.{ Answer, Question, Header }
  @type t :: %__MODULE__{
    sections: Map.t,    # section kind -> [ section entries ]
    offset: integer,
    segments: Map.t,    # name -> offset
    now: integer
  }
  @type builder_context :: { t, binary }
  @type section_kind :: :question | :answer | :authoritative | :additional


  @spec new() :: t
  def new() do
    %__MODULE__{
      sections: Map.new(question: [], answer: [], authoritative: [], additional: []),
      offset:   12, # sizeof header
      segments: Map.new(),
      now:      DnsPackets.MyTime.now()
    }
  end

  @spec new_section(t) :: PBS.t
  def new_section(builder) do
    %PBS{ content: [], segments: builder.segments, base_offset: builder.offset, offset: 0}
  end

  @spec add_question(t, String.t, integer) :: t
  def add_question(builder, name, type) do
    section = new_section(builder)
    section = Question.encode_into_section(section, name, type)
    bin = PBS.to_binary(section)
    new_list = [ bin | builder.sections[:question] ] 
    %{
      builder | 
      sections: Map.put(builder.sections, :question, new_list),
      offset: builder.offset + byte_size(bin),
      segments: section.segments
    }  
  end

  @spec add_answer(t, Answer.t, section_kind) :: t
  def add_answer(builder, answer, section_kind) do
    section = new_section(builder)
    section = Answer.encode_into_section(section, answer)
    bin = PBS.to_binary(section)
    new_list = [ bin | builder.sections[section_kind] ] 
    %{
      builder | 
      sections: Map.put(builder.sections, section_kind, new_list),
      offset: builder.offset + byte_size(bin),
      segments: section.segments
    }  
  end

  @spec to_packet(t, Keyword.t) :: iodata()
  def to_packet(builder, header_options) do
    s = builder.sections
    qd = s |> Map.get(:question)
    an = s |> Map.get(:answer)
    ns = s |> Map.get(:authoritative)
    ar = s |> Map.get(:additional)

    counts = [
      qd_count: length(qd),
      an_count: length(an),
      ns_count: length(ns),
      ar_count: length(ar),
    ]

    # iodata can be an improper list...
    [
      header_options |> Keyword.merge(counts) |> Header.new |> Header.to_binary,
      qd, an, ns, ar,
    ]
  end

end
