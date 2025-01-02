# Xhpoffice (super-alpha POC)

Xhpoffice is a POC to use the PHPOffice group of (great) libraries through elixir. In addition to a DSL to manipulate documents, it provides a `~PHP` sigil to run PHP code.
PHPWord and friends heavily use mutation, so we build a tree of calls in a functional style in Elixir, which is rewritten to use mutation in PHP.

### Write a document

Elixir code :

```elixir
import Xhpoffice.Word
output_path = Path.join(File.cwd!(), "output.docx")
doc = make_document()
{doc, section} = add_section(doc)
{doc, _section, _object} = add_text(doc, section, "How convenient !")
doc |> write(output_path) |> run!
```

This generates an AST :

```elixir
[
  [
    {:assign, "941995C2B5135245424CA0615E6CBDE7",
     {:static, "\\PhpOffice\\PhpWord\\IOFactory", "createWriter",
      [{:var, "674317FBD969EA74B1FF85C880B2CB92"}, "Word2007"]}},
    {:method, {:var, "941995C2B5135245424CA0615E6CBDE7"}, "save",
     ["<cwd>/output.docx"]}
  ],
  [
    {:assign, "536A810991F2B5C6E5C2CDE3EC99C921",
     {:method, {:var, "739CFE7AD01797F26E5C8B305A674886"}, "addText",
      ["How convenient !"]}}
  ],
  [
    {:assign, "739CFE7AD01797F26E5C8B305A674886",
     {:method, {:var, "674317FBD969EA74B1FF85C880B2CB92"}, "addSection", []}}
  ],
  {:assign, "674317FBD969EA74B1FF85C880B2CB92",
   {:new, "\\PhpOffice\\PhpWord\\PhpWord", []}}
]
```

Which is then compiled to PHP :

```php
<?php
$varF4F605C1FFBCF3CDC59374EBDF8B0DB8 = new \PhpOffice\PhpWord\PhpWord();
$var83F1F620C6BD472063B55A504626B8C8 = $varF4F605C1FFBCF3CDC59374EBDF8B0DB8->addSection();
$varF8440D2829E71AAC14AAFF423F0C15F9 = $var83F1F620C6BD472063B55A504626B8C8->addText("How convenient !");
$var65ADDF5337DA12DC1D21C4C819200176 = \PhpOffice\PhpWord\IOFactory::createWriter($varF4F605C1FFBCF3CDC59374EBDF8B0DB8,"Word2007");
$var65ADDF5337DA12DC1D21C4C819200176->save("<cwd>/xhpoffice/output.docx");
?>
```

### Check if PHP and composer are accessible :

```elixir
iex> Xhpoffice.Prerequisites.clear?()
true
```

### Write and run a PHP script, getting its output :

Output must go through the PHP function `elixir_return` and be JSON-encodable.
```elixir
iex> script = ~PHP"""
$foo = 5;
elixir_return(1 + 2 + $foo);
"""
iex> result = Xhpoffice.Php.run!(script)
8
```

### Write and run a PHP script, using input from Elixir :

Input must be provided in-order, is retrieved through `elixir_data` and should be JSON-encodable.

```elixir
iex> script = ~PHP"""
elixir_return(1 + 2 + elixir_data(0));
"""
iex> result = Xhpoffice.Php.run!(script, [5])
8
```

### Write and run a PHP script, installing and injecting PHPWord :

This creates a temporary folder, injects a composer.json file, installs dependencies, injects the autoloader, and runs your code.

```elixir
iex> script = ~PHP"""
elixir_return(1);
"""
iex> result = Xhpoffice.Phpword.run_with_phpword!(script)
```
