defmodule Cli do
  alias ReverseFile

  @spec main(args :: list(String.t())) :: any()
  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  @spec parse_args(args :: [binary()]) :: keyword()
  def parse_args(args) do
    {options, _, _} = OptionParser.parse(
      args,
      strict: [
        path: :string,
        offset: :integer
      ],
      aliases: [
        p: :path,
        o: :offset
      ]
    )
    options
  end

  @spec process(options :: keyword()) :: :ok
  def process(options) do
    default_offset = if options[:offset] == nil do
      Application.fetch_env!(:reverse_file, :default_offset_bytes)
    else
      options[:offset]
    end
    :ok = ReverseFile.main(options[:path], default_offset)
  end
end
