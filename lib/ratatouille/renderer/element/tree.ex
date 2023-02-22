defmodule Ratatouille.Renderer.Element.Tree do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias ExTermbox.Position

  alias Ratatouille.Renderer.{Canvas, Element, Text}

  @impl true
  def render(%Canvas{} = canvas, %Element{children: nodes}, _render_fn) do
    canvas
    |> render_nodes(nodes, "", true)
    |> Canvas.consume_rows(1)
  end

  def render_nodes(canvas, [], _depth, _root) do
    canvas
  end

  def render_nodes(
        %Canvas{render_box: box} = canvas,
        [
          %Element{tag: :tree_node, attributes: attrs, children: children}
          | siblings
        ],
        parent_prefix,
        root
      ) do
    last_child = Enum.empty?(siblings)
    text = to_string(attrs[:content])

    node_prefix = parent_prefix <> line(root, last_child)
    child_prefix = parent_prefix <> indent(root, last_child)

    node_prefix_offset = Position.translate_x(box.top_left, String.length(node_prefix))

    canvas
    |> Text.render(box.top_left, node_prefix)
    |> Text.render(node_prefix_offset, text, attrs)
    |> Canvas.consume_rows(1)
    |> render_nodes(children, child_prefix, false)
    |> render_nodes(siblings, parent_prefix, root)
  end

  @line "├── "
  @line_last "└── "

  @indent "│   "
  @indent_last "    "

  defp line(true, _last_child), do: ""
  defp line(_root, true), do: @line_last
  defp line(_root, false), do: @line

  defp indent(true, _last_child), do: ""
  defp indent(_root, true), do: @indent_last
  defp indent(_root, false), do: @indent
end
