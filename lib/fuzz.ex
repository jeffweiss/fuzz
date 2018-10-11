defmodule Fuzz do
  @moduledoc """
  Documentation for Fuzz.
  """
  require Logger
  use PropCheck

  @known_types [
    {"{{string}}", :utf8},
    {"{{int}}", :int},
    {"{{integer}}", :integer},
    {"{{large_int}", :large_int},
    {"{{float}}", :float},
    {"{{neg_integer}}", :neg_integer},
    {"{{non_neg_integer}}", :non_neg_integer},
    {"{{non_neg_float}}", :non_neg_float},
    {"{{boolean}}", :boolean}
  ]

  def main(args) do
    if Enum.member?(args, "--help") or Enum.member?(args, "-h"), do: display_help()

    Application.ensure_all_started(:httpc)
    args
    |> List.first
    |> tokenize_url
    |> check_url
    # check_url(url)
  end

  def display_help do
    """
    usage: fuzz <url_with_placeholder_tokens>

    Fuzz will use placeholders that will be replaced with randomly generated
    data at run-time.

    For example:

      fuzz "http://www.google.com/search?source=hp&btnK=Google+Search&q={{int}}"

    This will replace {{int}} with random integers and execute a Google search.
    Any response that is not between 200 (inclusive) and 300 (exclusive) will
    produce an error.

    Possible placeholders:
    #{for {placeholder, _} <- @known_types, do: "  #{placeholder}\n"}
    """
    |>
    IO.puts
    exit({:shutdown, 0})
  end

  def tokenize_url(url) do
    ~r/{{(.*?)}}/
      |> Regex.split(url, include_captures: true, trim: true)
      |> Enum.map(&replace_with_generator/1)
  end

  for {param, generator} <- @known_types do
    def replace_with_generator(unquote(param)), do: {PropCheck.BasicTypes, unquote(generator)}
  end
  # def replace_with_generator("{{string}}"), do: {PropCheck.BasicTypes, :utf8}
  # def replace_with_generator("{{int}}"), do: {PropCheck.BasicTypes, :integer}
  def replace_with_generator(other), do: other

  defp check_url(args) when is_list(args) do
    applied_args =
      args
      |> Enum.map(fn t when is_tuple(t) -> apply(elem(t, 0), elem(t, 1), [])
        other -> other
      end)
    quickcheck(
      forall blah <- applied_args do
        url =
          blah
          |> Enum.map(&to_string/1)
          |> IO.iodata_to_binary
          |> URI.encode
          |> to_charlist

        result = :httpc.request(url)
        # Logger.debug("#{inspect result}")
        case result do
          {:ok, {{_http_version, status_code, _reason}, _headers, _body}} ->
            is_ok?(status_code)
          {:ok, {status_code, _body}} ->
            is_ok?(status_code)
          _ ->
            false
        end
      end
    )
  end

  defp is_ok?(result) when result >= 200 and result < 300, do: true
  defp is_ok?(_), do: false
end
