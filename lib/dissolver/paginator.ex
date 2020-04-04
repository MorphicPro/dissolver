defmodule Dissolver.Paginator do
  use Phoenix.HTML

  @default [
    window: 3,
    range: true,
    next_label: "Next",
    previous_label: "Previous",
    first: true,
    first_label: "First",
    last: true,
    last_label: "Last"
  ]

  @moduledoc """
  Helpers to render the pagination links and more.
  """

  @doc """
  """
  @spec paginate(
          any,
          atom | %{page: any, params: map, total_pages: any},
          nil | maybe_improper_list | map
        ) :: [any]
  def paginate(conn, paginator, opts \\ []) do
    page = paginator.page
    total_pages = paginator.total_pages
    params = build_params(paginator.params, opts[:params])

    page
    |> previous_page
    |> first_page(page, opts[:window], opts[:first])
    |> page_list(page, total_pages, opts[:window], opts[:range])
    |> next_page(page, total_pages)
    |> last_page(page, total_pages, opts[:window], opts[:last])
    |> Enum.map(fn {l, p} ->
      {label_text(l, opts), p, build_url(conn, Map.put(params, "page", p)), page == p}
    end)
  end

  @doc """

  """
  @spec build_options(keyword) :: keyword
  def build_options(opts) do
    @default
    |> Keyword.merge(opts)
    |> Keyword.merge(params: Keyword.get(opts, :params, %{}))
    |> Keyword.merge(theme: Keyword.get(opts, :theme, Application.get_env(:dissolver, :theme)))
  end

  defp page_list(list, page, total, window, true) when is_integer(window) and window >= 1 do
    page_list =
      left(page, total, window)..right(page, total, window)
      |> Enum.map(fn n -> {n, n} end)

    list ++ page_list
  end

  defp page_list(list, _page, _total, _window, _range), do: list

  defp label_text(label, opts) do
    case label do
      :first -> opts[:first_label]
      :previous -> opts[:previous_label]
      :next -> opts[:next_label]
      :last -> opts[:last_label]
      _ -> label
    end
  end

  defp left(page, _total, window) when page - window <= 1 do
    1
  end

  defp left(page, _total, window), do: page - window

  defp right(page, total, window) when page + window >= total do
    total
  end

  defp right(page, _total, window), do: page + window

  defp previous_page(page) when page > 1 do
    [{:previous, page - 1}]
  end

  defp previous_page(_page), do: []

  defp next_page(list, page, total) when page < total do
    list ++ [{:next, page + 1}]
  end

  defp next_page(list, _page, _total), do: list

  defp first_page(list, page, window, true) when page - window > 1 do
    [{:first, 1} | list]
  end

  defp first_page(list, _page, _window, _included), do: list

  defp last_page(list, page, total, window, true) when page + window < total do
    list ++ [{:last, total}]
  end

  defp last_page(list, _page, _total, _window, _included), do: list

  defp build_url(conn, nil), do: conn.request_path

  defp build_url(conn, params) do
    "#{conn.request_path}?#{build_query(params)}"
  end

  defp build_query(params) do
    params |> Plug.Conn.Query.encode()
  end

  defp build_params(params, params2) do
    Map.merge(params, params2) |> normalize_keys()
  end

  defp normalize_keys(params) when is_map(params) do
    for {key, val} <- params, into: %{}, do: {to_string(key), val}
  end

  defp normalize_keys(params), do: params
end