defmodule Elihpword.Utils do
  @moduledoc """
  Utility functions for file manipulation operations.
  """

  @doc """
  Appends content to the end of a file.
  """
  def append!(file, contents) do
    c = File.read!(file)
    File.write!(file, c <> contents)
  end

  @doc """
  Prepends content to the beginning of a file.
  """
  def prepend!(file, contents) do
    c = File.read!(file)
    File.write!(file, contents <> c)
  end

  @doc """
  Wraps file content with prefix and suffix strings.
  """
  def encircle!(file, prefix, suffix) do
    c = File.read!(file)
    File.write!(file, prefix <> c <> suffix)
  end
end
