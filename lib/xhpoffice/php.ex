defmodule Xhpoffice.Php do
  @moduledoc """
  A module for executing PHP code from within Elixir.
  Provides functionality to create temporary PHP files, inject seed data,
  and execute PHP scripts with output handling.
  """

  require Logger

  @doc """
  Creates a temporary PHP file with a random name.

  Returns the path to the created file.
  """
  def get_tmp_file! do
    path = Path.join(System.tmp_dir!(), Base.encode16(:crypto.strong_rand_bytes(8))) <> ".php"
    File.touch!(path)
    path
  end

  @doc """
  Creates a PHP script from the given body text using a sigil.

  Returns the path to the created PHP file.
  """
  def sigil_PHP(body, _opts) do
    with file <- get_tmp_file!() do
      contents = """
      <?php
      #{body}
      ?>
      """

      File.write(file, contents)
      file
    end
  end

  @doc """
  Injects seed data and output handling code into an existing PHP file.

  Takes a file path and optional seed data, returns path to the modified file.
  """
  def inject_seed(file, seed) do
    prequel = """
    <?php
    global $__xhpoffice_seed;
    $__xhpoffice_seed = json_decode("#{Jason.encode!(seed)}");
    global $__xhpoffice_output;
    $__xhpoffice_output = null;

    function elixir_data($index) {
      global $__xhpoffice_seed;
      return $__xhpoffice_seed[$index];
    }

    function elixir_return($value) {
      global $__xhpoffice_output;
      $__xhpoffice_output = $value;
    }
    ?>
    """

    sequel = """
    <?php
    echo json_encode($__xhpoffice_output);
    ?>
    """

    path = String.replace(file, ".php", ".elixir.php")
    File.cp(file, path)
    Xhpoffice.Utils.encircle!(path, prequel, sequel)
    path
  end

  @doc """
  Executes a PHP file and returns its output.

  Takes a file path and optional seed data. Returns the decoded JSON output from the PHP script.
  Throws an error tuple if the PHP execution fails.
  """
  def run!(file, seed \\ nil, transformer \\ & &1) do
    path = transformer.(inject_seed(file, seed))

    case System.cmd("php", [path]) do
      {output, 0} ->
        Jason.decode!(output)

      {output, _} ->
        contents = File.read!(path)
        Logger.error(contents)
        throw({output, :ephp, contents})
    end
  end
end
