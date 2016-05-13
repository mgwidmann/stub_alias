defmodule StubAlias do
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
