defmodule DnsPackets.RRHelpers do 

  defmodule InjectTypes do
    # There must be a less ugly way of generating the AST...
    defp type_union([t]) do
      t  
    end
    defp type_union([s|t]) do 
      {:|, [], [s, type_union(t)] }
    end

    defmacro __before_compile__(env) do
      type_numbers = Module.get_attribute(env.module, :rr_names, [])
        |> Enum.map(&elem(&1, 0))
        |> type_union()  
      type_names = Module.get_attribute(env.module, :rr_names, [])
        |> Enum.map(&elem(&1, 1))
        |> type_union()  
      quote do 
        @type rr_type_numbers :: unquote(type_numbers)
        @type rr_type_names   :: unquote(type_names)
      end
    end
  end



  defmacro __using__(_opts) do
    quote do
      require DnsPackets.RRHelpers
      import  DnsPackets.RRHelpers
      alias   DnsPackets.PacketBuilder.Section, as: PBS
      Module.register_attribute(__MODULE__, :rr_names, accumulate: true)

      @before_compile InjectTypes

      @spec encode_into_section(PBS.t, DnsPackets.Packets.Answer.t) :: PBS.t

    end
  end


  defmacro rr(name, type, desc, content) do
    fields = content |> Keyword.keys
    modname = name |> to_string |> String.capitalize |> String.to_atom


    modname = { :__aliases__, [], [ modname ]}
    code = (quote do
      defmodule unquote(modname) do
        @moduledoc unquote(desc)
        alias DnsPackets.Packets

        defstruct unquote(fields)

        { :compile, inline: [ type: 0 ] }
        def type, do: unquote(type)

        @spec decode(DnsPackets.Packets.parse_context, integer) :: { %__MODULE__{}, DnsPackets.Packets.parse_context, integer}
        def decode(context, length) do
          { setters, context, length_left } = 
            unquote(content) 
            |> Enum.reduce(
              {[], context, length},
              fn {name, accessor}, { result, context, length_left} ->
                { value, context, length_left } = accessor.decode(context, length_left) 
                { [ { name, value } | result ], context, length_left}
                end)
          { struct(__MODULE__, setters), context, length_left }
        end

        # @spec encode_into_section(PacketBuilder.Section.t, %__MODULE__{}) :: PacketBuilder.Section.t
        def encode_into_section(section, answer) do
          unquote(content)
          |> Enum.reduce(section, fn {name, accessor}, section ->
            accessor.encode_into_section(section, Map.get(answer, name))
          end)
        end

        # @spec format(%__MODULE__{}) :: String.t
        def format(val) do
            unquote(content) 
            |> Enum.map(
              fn {name, accessor} ->
                accessor.decode(val.unquote(name))
                end)
        end
      end

      @spec decode(DnsPackets.Packets.parse_context, unquote(type), integer) :: { %unquote(modname){}, DnsPackets.Packets.parse_context, integer}
      def decode(context, unquote(type), length) do
        unquote(modname).decode(context, length)
      end

      def encode_into_section(section, answer = %DnsPackets.Packets.Answer{atype: unquote(type)}) do
        unquote(modname).encode_into_section(section, answer.rdata)
      end

      Module.put_attribute(__MODULE__, :rr_names, { unquote(type), unquote(modname)})
    end)
    # IO.puts(Macro.to_string(code))
    code
  end
end
