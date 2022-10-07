defmodule RRHelpers do
  
  defmacro __using__(_opts) do
    quote do
    require RRHelpers
      import RRHelpers
    end
  end


  defmacro rr(name, type, desc, content) do
    fields = content |> Keyword.keys
    modname = name |> to_string |> String.capitalize |> String.to_atom


    modname = { :__aliases__, [], [ modname ]}
    code = (quote do
      defmodule unquote(modname) do
      @moduledoc unquote(desc)
      
      defstruct unquote(fields)

      { :compile, inline: [ type: 0 ] }
      def type, do: unquote(type)

      @spec decode(Packet.parse_context) :: { %__MODULE__{}, Packet.parse_context}
      def decode(context) do
        { setters, context } = 
          unquote(content) 
          |> Enum.reduce(
            {[], context},
            fn {name, accessor}, { result, context } ->
              { value, context } = accessor.decode(context) 
              { [ { name, value } | result ], context}
              end)
        { struct(__MODULE__, setters), context }
      end
      end

      @spec decode(Packet.parse_context, unquote(type)) :: { %unquote(modname){}, Packet.parse_context}
      def decode(context, unquote(type)) do
        unquote(modname).decode(context)
      end
    end)
    # IO.puts(Macro.to_string(code))
    code
  end
end
