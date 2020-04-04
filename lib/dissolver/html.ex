defmodule Dissolver.HTML do
  use Phoenix.HTML
  alias Dissolver.HTML
  import Dissolver.Paginator, only: [build_options: 1]

  @themes [:bootstrap, :foundation, :semantic, :simple]

  @moduledoc """
  Html helpers to render the pagination links and more,
  import the `Dissolver.HTML` in your view module.

      defmodule MyApp.ProductView do
        use MyApp.Web, :view
        import Dissolver.HTML
      end

  now you have these view helpers in your template file.
      <%= paginate @conn, @page %>

  Where `@page` is a `%Dissolver{}` struct returned from `Repo.paginate/2`.

  `paginate` helper takes keyword list of `options` and `params`.
    <%= paginate @conn, @page, window: 5, next_label: ">>", previous_label: "<<", first: true, last: true, first_label: "First", last_label: "Last" %>
  """

  @doc """
  Generates the HTML pagination links for a given page returned by Dissolver.

  The `theme` indicates which CSS framework you are using. The default is
  `:bootstrap`, but you can add your own using the `Dissolver.HTML.do_paginate/3` function
  if desired. Dissolver provides few themes out of the box:

      #{inspect(@themes)}

  Example:

      iex> Dissolver.HTML.paginate(@conn, @dissolver)

  Path can be overriden by adding setting `:path` in the `opts`.
  For example:

      Dissolver.HTML.paginate(@conn, @dissolver, path: product_path(@conn, :index, foo: "bar"))

  Additional panigation class can be added by adding setting `:class` in the `opts`.
  For example:

      Dissolver.HTML.paginate(@conn, @dissolver, theme: :boostrap4, class: "paginate-sm")
  """
  defmacro __using__(_opts \\ []) do
    quote do
      import Dissolver.HTML
    end
  end

  def paginate(conn, paginator, opts \\ []) do
    opts = build_options(opts)

    conn
    |> Dissolver.Paginator.paginate(paginator, opts)
    |> render_page_list(opts)
  end

  defp render_page_list(page_list, opts) do
    case opts[:theme] do
      :bootstrap -> HTML.Bootstrap.generate_links(page_list, opts[:class])
      :bootstrap4 -> HTML.Bootstrap4.generate_links(page_list, opts[:class])
      :foundation -> HTML.Foundation.generate_links(page_list, opts[:class])
      :semantic -> HTML.Semantic.generate_links(page_list, opts[:class])
      :materialize -> HTML.Materialize.generate_links(page_list, opts[:class])
      _ -> HTML.Simple.generate_links(page_list, opts[:class])
    end
  end
end
