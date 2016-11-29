defmodule StubAlias do
  @moduledoc """
  Replaces `alias MyModule` calls with a different module based upon environment configuration. Instead of using
  mocks to mock out undesired function calls or side effects, use `stub_alias/2` to replace that call to a different
  module without mocking. `StubAlias` replaces your `alias SideEffectModule` calls at test time with `alias NonSideEffectModule`
  or a module of your choice based upon configuration.

  This is useful for external APIs in which HTTP calls are necessary, or database interactions that are undesired. To use
  add an import to `StubAlias` and then replace your `alias` calls with `stub_alias`. Then in the `:test` environment (or
  wherever) add configuration mapping to the new module intended to use at test time.

  Example:

      defmodule UserService do
        import StubAlias
        stub_alias HTTPoison

        def find(id) do
          HTTPoison.get!("http://www.api.com/v1/users/\#{id}") |> handle_response()
        end

        # Private method so can't be tested directly
        defp handle_response(%HTTPoison.Response{status_code: 200, body: body}) do
          Poison.decode!(body) # Handle serialization logic, ect
        end
        defp handle_response(%HTTPoison.Response{status_code: code}) when code != 200 do
          :error
        end
      end

  Given the following configuration for the test environment:

      config :stub_alias,
        "HTTPoison": MyApp.Stubs.HTTPoison

  And then in `test/support/stubs/httpoison.ex` a simple file like:

      defmodule MyApp.Stubs.HTTPoison do
        # Test time call goes here instead of HTTPoison and no request is made!
        def get!("http://www.api.com/v1/users/1") do
          %{users: []} # Data we want to test against, could easily be an agent to allow the test to set the data
          |> Poison.encode!
        end
      end
  """

  @doc """
  Use to replace `alias` calls with environment specific modules. See `StubAlias` for more information.
  """
  defmacro stub_alias(aliases, opts \\ []) do
    _stub_alias(aliases, opts)
  end

  defp _stub_alias({:__aliases__, _, module}, opts) do
    concatted_module = module |> Enum.map(&to_string/1) |> Enum.join(".") |> String.to_atom
    quote do
      alias unquote(Module.concat(:Elixir, Application.get_env(:stub_alias, concatted_module, concatted_module))), unquote(opts)
    end
  end
  defp _stub_alias({{:., [], [{:__aliases__, _, base_modules}, :{}]}, [], aliases}, opts) do
    {:__block__, [],
      Enum.map(aliases, fn({:__aliases__, [alias: false], module}) ->
        _stub_alias({:__aliases__, [alias: false], base_modules ++ module}, opts)
      end)
    }
  end
  if Mix.env == :test do
    defp _stub_alias(unknown, opts) do
      raise "Received unhandled code: #{inspect unknown} with opts #{inspect opts}"
    end
  end
end
