defmodule StubAliasTest do
  use ExUnit.Case, async: false
  import StubAlias
  doctest StubAlias

  setup do
    Application.delete_env(:stub_alias, :"MyModule")
    Application.delete_env(:stub_alias, :"MyModule.MyThing")
    Application.delete_env(:stub_alias, :"MyModule.Foo")
    Application.delete_env(:stub_alias, :"MyModule.Bar")
    :ok
  end

  @stub quote(do: stub_alias MyModule)
  test "unconfigured" do
    assert "alias(MyModule, [])" == Macro.expand(@stub, __ENV__) |> Macro.to_string
  end

  test "configured" do
    IO.puts "configured output:"
    Application.put_env(:stub_alias, :"MyModule", Stubs.MyModule)
    assert "alias(Stubs.MyModule, [])" == Macro.expand(@stub, __ENV__) |> Macro.to_string
  end

  @stub_nested quote(do: stub_alias MyModule.MyThing)
  test "nested unconfigured" do
    assert "alias(MyModule.MyThing, [])" == Macro.expand(@stub_nested, __ENV__) |> Macro.to_string
  end

  test "nested configured" do
    Application.put_env(:stub_alias, :"MyModule.MyThing", Stubs.MyModule.MyThing)
    assert "alias(Stubs.MyModule.MyThing, [])" == Macro.expand(@stub_nested, __ENV__) |> Macro.to_string
  end

  @stub_as quote(do: stub_alias(MyModule, as: Other))
  test "with as option unconfigured" do
    assert "alias(MyModule, as: Other)" == Macro.expand(@stub_as, __ENV__) |> Macro.to_string
  end

  test "with as option configured" do
    Application.put_env(:stub_alias, :"MyModule", Stubs.MyModule)
    assert "alias(Stubs.MyModule, as: Other)" == Macro.expand(@stub_as, __ENV__) |> Macro.to_string
  end

  @stub_multi quote(do: stub_alias(MyModule.{Foo, Bar}))
  test "multi unconfigured" do
    assert """
    (
      alias(MyModule.Foo, [])
      alias(MyModule.Bar, [])
    )
    """ |> String.rstrip  == Macro.expand(@stub_multi, __ENV__) |> Macro.to_string
  end

  test "multi configured" do
    Application.put_env(:stub_alias, :"MyModule.Foo", Stubs.MyModule.Foo)
    Application.put_env(:stub_alias, :"MyModule.Bar", Stubs.MyModule.Bar)
    assert """
    (
      alias(Stubs.MyModule.Foo, [])
      alias(Stubs.MyModule.Bar, [])
    )
    """ |> String.rstrip  == Macro.expand(@stub_multi, __ENV__) |> Macro.to_string
  end
end
