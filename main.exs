defmodule ReverseFileScript do
  @moduledoc """
  Reverse any file
  """
  @spec main() :: nil
  def main() do
    # file_name = "logs/boot.log"
    # file_name = "logs/Zookeeper.log"
    file_name = "logs/HPC.log"
    {:ok, descriptor} = :file.open(file_name, [:read, :binary])
    file_size = get_file_size(file_name)
    # default_offset = 1024 * 1024 * 1024   # 1GB
    default_offset = 1024 * 1024  # 1MB
    # default_offset = 1024   # 1KB
    read_file_bytes = 0
    reverse_file(descriptor, file_size, default_offset, read_file_bytes, "")
    :file.close(descriptor)
  end

  def get_file_size(file_name) do
    {:ok, file_info} = :file.read_file_info(file_name)
    elem(file_info, 1)
  end

  @spec reverse_file(
    descriptor :: binary,
    file_size :: integer,
    default_offset :: integer,
    position_from_end_file :: integer,
    previous_chunk :: binary
  ) :: nil
  def reverse_file(descriptor, file_size, default_offset, position_from_end_file, previous_chunk) do
    bytes_to_read = calculate_bytes_to_read(file_size, position_from_end_file, default_offset)
    position_from_end_file = position_from_end_file + bytes_to_read
    current_chunk = read_chunk(descriptor, position_from_end_file, bytes_to_read)
    chunk = join_my_chunks(current_chunk, previous_chunk)
    {line_part, lines} = split_chunk_in_lines(chunk)
    print_reverse_lines(lines)
    if !last_read?(file_size, position_from_end_file) do
      reverse_file(descriptor, file_size, default_offset, position_from_end_file, line_part)
    else
      print_line(line_part)
    end
  end

  @spec read_chunk(
    file_name :: binary,
    position_from_end_file :: integer,
    bytes_to_read :: integer
  ) :: binary
  def read_chunk(descriptor, position_from_end_file, bytes_to_read) do
    {:ok, location} = :file.position(descriptor, {:eof, -position_from_end_file})
    {:ok, chunk} = :file.pread(descriptor, location, bytes_to_read)
    chunk
  end


  @spec join_my_chunks(current :: binary, previous :: binary) :: binary
  def join_my_chunks(current, previous) do
    current <> previous
  end


  @spec split_chunk_in_lines(chunk :: binary) :: {binary, [binary]}
  def split_chunk_in_lines(chunk) do
    [first | rest] = String.split(chunk, "\n")
    {first, rest}
  end


  @spec print_reverse_lines(lines :: binary) :: :ok
  def print_reverse_lines([]), do: :ok
  def print_reverse_lines([line | rest]) do
    print_reverse_lines(rest)
    print_line(line)
  end


  @spec print_line(line :: binary) :: :ok
  def print_line(line), do: IO.puts(line)


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

  @spec last_read?(file_size :: integer, current_read_bytes :: integer) :: boolean
  def last_read?(file_size, current_read_bytes) do
    current_read_bytes == file_size
  end
end

ReverseFileScript.main
