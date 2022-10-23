defmodule PacketBuilderSectionTest do
  use ExUnit.Case
  alias DnsPackets.PacketBuilder, as: PB
  alias DnsPackets.PacketBuilder.Section, as: PBS

  setup do
    pb = PB.new
    %{ section: PB.new_section(pb) }
  end

  defp enc(str), do: << String.length(str) :: 8, str :: binary >>


  test "initially empty", t  do
    assert PBS.to_binary(t.section) == <<>>
  end

  test "can add a simple name", t do
    section = PBS.add_name(t.section, "wombat")
    assert PBS.to_binary(section) == << enc("wombat") :: binary, 0 :: 8 >>
  end

  test "can add a simple dotted name", t do
    section = PBS.add_name(t.section, "wombat.koala")
    assert PBS.to_binary(section) == << 
      enc("wombat") :: binary,
      enc("koala")  :: binary,
      0 :: 8
    >>
  end

  test "can add a dotted name with a duplicate", t do
    # this should NOT compress the second "wombat", and that would
    # result in "wombat.koala.wombat.koala"
    section = PBS.add_name(t.section, "wombat.koala.wombat")
    assert PBS.to_binary(section) == << 
      enc("wombat") :: binary,
      enc("koala")  :: binary,
      enc("wombat") :: binary,
      0 :: 8
    >>
  end

end
