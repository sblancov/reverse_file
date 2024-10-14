defmodule ReverseFile do
  @moduledoc """
  ReverseFile module let us to reverse a file line by line.
  """

  @spec main(
    file_name :: binary(),
    default_offset :: integer()
  ) :: :ok | {:error, atom()}
  def main(file_name, default_offset) do
    {:ok, descriptor} = :file.open(file_name, [:read, :binary])
    file_size = get_file_size(file_name)
    read_file_bytes = 0
    reverse_file(descriptor, file_size, default_offset, read_file_bytes, "")
    :file.close(descriptor)
  end

  @spec reverse_file(
    descriptor :: :file.io_device(),
    file_size :: integer,
    default_offset :: integer,
    position_from_end_file :: integer,
    previous_chunk :: binary
  ) :: :ok
  def reverse_file(descriptor, file_size, default_offset, position_from_end_file, previous_chunk) do
    bytes_to_read = calculate_bytes_to_read(file_size, position_from_end_file, default_offset)
    position_from_end_file = position_from_end_file + bytes_to_read
    current_chunk = read_chunk(descriptor, position_from_end_file, bytes_to_read)
    chunk = join_chunks(current_chunk, previous_chunk)
    {line_part, lines} = split_chunk_in_lines(chunk)
    print_reverse_lines(lines)
    if !last_read?(file_size, position_from_end_file, default_offset) do
      reverse_file(descriptor, file_size, default_offset, position_from_end_file, line_part)
    else
      print_line(line_part)
    end
    :ok
  end

  @spec get_file_size(
    file_name :: binary()
  ) :: integer()
  def get_file_size(file_name) do
    {:ok, file_info} = :file.read_file_info(file_name)
    elem(file_info, 1)
  end

  @spec read_chunk(
    descriptor :: :file.io_device(),
    position_from_end_file :: integer(),
    bytes_to_read :: integer()
  ) :: binary()
  def read_chunk(descriptor, position_from_end_file, bytes_to_read) do
    {:ok, location} = :file.position(descriptor, {:eof, -position_from_end_file})
    {:ok, chunk} = :file.pread(descriptor, location, bytes_to_read)
    chunk
  end

  @spec join_chunks(current :: binary, previous :: binary) :: binary
  def join_chunks(current, previous) do
    current <> previous
  end

  @spec split_chunk_in_lines(chunk :: binary) :: {binary, [binary]}
  def split_chunk_in_lines(chunk) do
    [first | rest] = String.split(chunk, "\n")
    {first, rest}
  end

  @spec print_reverse_lines(lines :: list(binary)) :: :ok
  def print_reverse_lines([]), do: :ok
  def print_reverse_lines([line | rest]) do
    print_reverse_lines(rest)
    print_line(line)
  end

  @spec print_line(line :: binary) :: :ok
  def print_line(line) do
    IO.puts(line)
  end

  @spec calculate_bytes_to_read(
    file_size :: integer, current_read_bytes :: integer,
    default_offset :: integer
  ) :: integer
  def calculate_bytes_to_read(
    file_size, current_read_bytes, default_offset
  ) when file_size - current_read_bytes < default_offset do
    file_size - current_read_bytes
  end
  def calculate_bytes_to_read(_size, _current_read_bytes, default_offset) do
    default_offset
  end

  @spec last_read?(
    file_size :: integer, current_read_bytes :: integer,
    default_offset :: integer
  ) :: boolean
  def last_read?(file_size, current_read_bytes, default_offset) do
    default_offset + current_read_bytes >= file_size
  end
end
