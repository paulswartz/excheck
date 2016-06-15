defmodule ExCheck.Formatter do
  use GenEvent
  alias ExUnit.CLIFormatter, as: CF

  @moduledoc """
  Helper module for properly formatting test output.
  """

  @doc false
  def init(opts) do
    CF.init(opts)
  end

  @doc false
  def handle_event(event = {:suite_finished, _run_us, _load_us}, config) do
    new_cfg = %{config | tests_counter: update_counter(config.tests_counter, ExCheck.IOServer.total_tests)}
    print_property_test_errors
    CF.handle_event(event, new_cfg)
  end
  def handle_event(event, config) do
    CF.handle_event(event, config)
  end

  defp update_counter(counter, total) when is_integer(counter) do
    counter + total
  end
  defp update_counter(%{property: property} = counter, total) do
    %{counter | property: property + total}
  end
  defp update_counter(counter, total) do
    counter
    |> Map.put(:property, total)
  end
  defp print_property_test_errors do
    ExCheck.IOServer.errors
    |> List.flatten
    |> Enum.map(fn({msg, value_list}) ->
      :io.format(msg, value_list)
    end)
  end
end
