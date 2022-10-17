defmodule DnsPackets.MyTime do 

  if Mix.env != :test do

    def now() do
      System.system_time(:second)
    end


  else

    @me MockeryOfTime
    use Agent

    def start_link(now), do: Agent.start_link(fn -> now end, name: @me)

    def now, do: Agent.get(@me, &(&1))

    defmacro set_now(new_now, do: blk) do 
      quote do
        old_time = Agent.get_and_update(unquote(@me), fn old_time -> { old_time, unquote(new_now) } end)
        value = unquote(blk)
        Agent.update(unquote(@me), fn _ -> old_time end)
        value
      end
    end
  end
end
