defmodule Elihpword.Api do
  @moduledoc """
  API module for managing document sections and operations.
  """

  @doc """
  Updates a section in the sections map using the provided function.
  """
  def update_section(sections, section_id, fun) do
    Map.update(sections, section_id, %{}, fn s ->
      fun.(s)
    end)
  end

  @doc """
  Adds an item to a section's elements.
  """
  def add_section_item(section, object_id, object) do
    Map.update(section, :elements, %{}, fn v ->
      Map.put(v, object_id, object)
    end)
  end

  @doc """
  Updates sections in a document using the provided function.
  """
  def update_sections(document, fun) do
    Map.put(
      document,
      :sections,
      Map.update(document, :sections, %{}, fn v ->
        fun.(v)
      end)
    )
  end

  @doc """
  Pushes new calls onto the document's call stack.
  """
  def push_calls(document, calls) do
    Map.update(document, :calls, [], fn v ->
      [calls | v]
    end)
  end
end
