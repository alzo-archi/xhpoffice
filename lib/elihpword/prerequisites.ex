defmodule Elihpword.Prerequisites do
  @doc """
  Checks if all PHP prerequisites are met.

  Returns true if PHP is installed, PHP version is >= 8.1.0, and Composer is installed.
  Returns false if any of the prerequisites fail.
  """
  def clear?() do
    Enum.reduce(
      [&php_installed?/0, &php_version_satisfying?/0, &composer_installed?/0],
      true,
      &(&1.() && &2)
    )
  end

  defp php_installed? do
    case System.cmd("php", ["--version"]) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  defp php_version_satisfying? do
    case System.cmd("php", ["--version"]) do
      {output, 0} ->
        version = output |> String.split("\n") |> List.first() |> String.split(" ") |> Enum.at(1)
        Version.match?(version, ">= 8.1.0")

      _ ->
        false
    end
  rescue
    _ -> false
  end

  defp composer_installed? do
    case System.cmd("composer", ["--version"]) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    _ -> false
  end
end
