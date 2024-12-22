defmodule Elihpword.Phpword do
  @moduledoc """
  Module for running PHP scripts with PHPWord support.
  Handles the setup and injection of Composer dependencies for PHPWord.
  """

  defp prepare_folder(script_path) do
    basename = Path.basename(script_path)
    dirname = Path.dirname(script_path)
    folder = String.slice(basename, 0..8)
    folder_path = Path.join(dirname, folder)
    new_script_path = Path.join(folder_path, basename)
    File.mkdir(folder_path)
    :ok = File.cp(script_path, new_script_path)
    {folder_path, new_script_path}
  end

  @doc false
  defp write_composer_json(folder_path) do
    contents = """
    {
        "name": "alzo-archi/elihpword",
        "type": "project",
        "autoload": {
            "psr-4": {
                "AlzoArchi\\\\Elihpword\\\\": "src/"
            }
        },
        "authors": [],
        "require": {
            "phpoffice/phpword": "^1.3"
        }
    }
    """

    File.write!(Path.join(folder_path, "composer.json"), contents)
  end

  @doc false
  defp run_composer(folder_path) do
    System.cmd("composer", ["install"], cd: folder_path)
  end

  @doc false
  defp inject_composer(script_path) do
    composer_injection = """
    <?php
    require_once "vendor/autoload.php";
    ?>
    """

    Elihpword.Utils.prepend!(script_path, composer_injection)
  end

  @doc """
  Runs a PHP script with PHPWord support by:
  1. Creating a new folder and copying the script
  2. Setting up composer.json with PHPWord dependency
  3. Installing dependencies via Composer
  4. Injecting the Composer autoloader
  5. Running the prepared PHP script
  """
  def run_with_word!(script_path) do
    {folder_path, new_script_path} = prepare_folder(script_path)
    write_composer_json(folder_path)
    run_composer(folder_path)
    inject_composer(new_script_path)
    Elihpword.Php.run!(new_script_path)
  end
end
