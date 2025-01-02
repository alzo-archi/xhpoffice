defmodule Xhpoffice.Compiler do
  @moduledoc """
  Compiles an Xhpoffice document into PHP code.
  Takes an AST-like document structure and generates the corresponding PHP syntax.
  """
  def compile(document) do
    do_compile(document.calls)
  end

  def do_compile(calls) do
    spells = calls |> Enum.reverse() |> List.flatten()

    output =
      for spell <- spells do
        eval(spell)
      end

    joined = Enum.join(output, "\n")

    joined
  end

  def map_args(args), do: Enum.map_join(args, ",", &eval/1)
  def dollar(id), do: "$var#{id}"
  def eval({:assign, id, expr}), do: "#{dollar(id)} = #{eval(expr)};"
  def eval({:new, class, args}), do: "new #{class}(#{map_args(args)});"
  def eval({:var, id}), do: dollar(id)
  def eval({:method, subject, name, args}), do: "#{eval(subject)}->#{name}(#{map_args(args)});"
  def eval({:static, class, name, args}), do: "#{class}::#{name}(#{map_args(args)});"
  def eval(value) when is_binary(value), do: Jason.encode!(value)
end
