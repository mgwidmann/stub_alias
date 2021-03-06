# Stub Alias [![Hex.pm](https://img.shields.io/hexpm/v/stub_alias.svg)]()

A simple macro to allow switching `alias` statements out with different values based upon environment.

## Installation

[Available in Hex](https://hex.pm/packages/stub_alias), the package can be installed as:

Add stub_alias to your list of dependencies in `mix.exs`:

    def deps do
      [{:stub_alias, "~> 0.1.0"}]
    end

`StubAlias` is a compile time dependency and can be left out of the `applications` list.

## Usage

In your code you may have some alias statements like the following:

**EXAMPLE**

```elixir
defmodule MyModule do
  alias MyModule.Foo

  def stuff() do
    Foo.do_something_with_side_effects
  end
end
```

Obviously, during testing, it makes it more difficult to test the function `stuff/0` since it calls another function which has undesierable side effects (or requires some system state like a running GenServer).

If you add to your `config/test.exs` configuration like the following:

```elixir
config :stub_alias,
  "MyModule.Foo": MyModule.Stubs.Foo
```

Setup your mix.exs to compile in the `test/support` folder [like in Phoenix](https://github.com/phoenixframework/phoenix/blob/master/installer/templates/new/mix.exs#L12). Then replace `alias MyModule.Foo` with `stub_alias MyModule.Foo` (after `import StubAlias` of course):

**SOLUTION**

`lib/my_module.ex`
```elixir
defmodule MyModule do
  import StubAlias
  stub_alias MyModule.Foo

  def stuff() do
    Foo.do_something_with_side_effects
  end
end
```

`test/support/foo.ex`
```elixir
defmodule MyModule.Stubs.Foo do
  def do_something_with_side_effects() do
    # Return hard coded data or get data from an agent or whatever you please
    results = %{}
    results
  end
end
```


In the `:test` Mix.env, your aliases will be replaced as desired. This then allows you to have a compiled `test/support` folder which supplies those stubs, making easy explicit replacements of code at test time.
