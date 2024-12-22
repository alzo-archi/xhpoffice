defmodule Elihpword do
  @moduledoc """
  Module for generating Word documents using PHPWord through Elixir.
  Provides functions to create documents, add sections and text, and save to disk.
  """

  @doc false
  defp random_string() do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end

  @doc """
  Creates a new empty document.
  Returns a document struct with a unique ID, empty sections map, and initial PHP call.
  """
  def make_document() do
    id = random_string()

    %{
      id: id,
      sections: %{},
      calls: [
        {:assign, id, {:new, "\\PhpOffice\\PhpWord\\PhpWord", []}}
      ]
    }
  end

  @doc """
  Adds a new section to the document.
  Returns tuple of {updated_document, section_id}.
  """
  def add_section(document) do
    id = random_string()

    updated =
      document
      |> Elihpword.Api.update_sections(fn v ->
        Map.put(v, id, make_section(id))
      end)
      |> Elihpword.Api.push_calls([
        {:assign, id, {:method, {:var, document.id}, "addSection", []}}
      ])

    {updated, id}
  end

  @doc """
  Creates a new section struct with the given ID.
  """
  def make_section(id) do
    %{id: id, elements: %{}}
  end

  @doc """
  Adds text to a section in the document.
  Takes a document, section_id and text string.
  Returns tuple of {updated_document, section_id, object_id}.
  """
  def add_text(document, section_id, text) do
    object_id = random_string()

    updated =
      document
      |> Elihpword.Api.update_sections(fn v ->
        Elihpword.Api.update_section(v, section_id, fn s ->
          s |> Elihpword.Api.add_section_item(object_id, {:text, text})
        end)
      end)
      |> Elihpword.Api.push_calls([
        {:assign, object_id, {:method, {:var, section_id}, "addText", [text]}}
      ])

    {updated, section_id, object_id}
  end

  @doc """
  Writes the document to disk at the given path.
  Returns the document with added write calls.
  """
  def write(document, path) do
    writer_id = random_string()

    document
    |> Elihpword.Api.push_calls([
      {:assign, writer_id,
       {:static, "\\PhpOffice\\PhpWord\\IOFactory", "createWriter",
        [{:var, document.id}, "Word2007"]}},
      {:method, {:var, writer_id}, "save", [path]}
    ])
  end

  @doc """
  Compiles and executes the document generation.
  """
  def run!(document) do
    document
    |> Elihpword.Compiler.compile()
    |> Elihpword.Php.sigil_PHP([])
    |> Elihpword.Phpword.run_with_word!()
  end

  @doc """
  Creates a sample document with some text and saves it to output.docx.
  """
  def sample() do
    document = make_document()
    {document, section_id} = add_section(document)
    {document, _section_id, _object} = add_text(document, section_id, "How convenient !")
    ready_to_write = write(document, Path.join(File.cwd!(), "output.docx"))
    ready_to_write |> run!
  end
end
