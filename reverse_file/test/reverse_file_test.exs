defmodule ReverseFileTest do
  use ExUnit.Case
  # doctest ReverseFile

  describe "get file size" do
    setup do
      file_name = "test/fixtures/example.txt"
      {
        :ok,
        file_name: file_name,
      }
    end

    test "example.txt", context do
      current = ReverseFile.get_file_size(context[:file_name])
      expected = 30
      assert current == expected
    end
  end

  describe "read chunks:" do
    setup do
      file_name = "test/fixtures/example.txt"
      {:ok, descriptor} = :file.open(file_name, [:read, :binary])
      {
        :ok,
        descriptor: descriptor
      }
    end

    parameters = [
      {"last", 5, 5, "vwxy\n"},
      {"first", 30, 5, "abcde"}
    ]
    for {chunk, position_from_end_file, bytes_to_read, expected} <- parameters do
      test "read the #{chunk} chunk", context do
        assert ReverseFile.read_chunk(
          context[:descriptor],
          unquote(position_from_end_file),
          unquote(bytes_to_read)
        ) == unquote(expected)
      end
    end
  end

  describe "join chunks" do
    parameters = [
      {"abc", "de", "abcde"},
      {"", "de", "de"},
      {"abc", "", "abc"}
    ]
    for {current, previous, expected} <- parameters do
      test "join #{current} and #{previous} chunks" do
        assert ReverseFile.join_chunks(unquote(current), unquote(previous)) == unquote(expected)
      end
    end
  end

  describe "split chunk in lines:" do
    parameters = [
      {"ab\ncd", {"ab", ["cd"]}},
      {"ab\ncd\nabcd", {"ab", ["cd", "abcd"]}},
    ]
    for {chunk, expected} <- parameters do
      test "chunk #{chunk}" do
        assert ReverseFile.split_chunk_in_lines(unquote(chunk)) == unquote(expected)
      end
    end
  end

  describe "calculate bytes to read:" do
    parameters = [
      {30, 0, 5, 5},
      {30, 27, 5, 3}
    ]
    for {file_size, current_read_bytes, default_offset, expected} <- parameters do
      test "with file_size=#{file_size} current_read_bytes=#{current_read_bytes} default_offset=#{default_offset}" do
        assert ReverseFile.calculate_bytes_to_read(
          unquote(file_size), unquote(current_read_bytes), unquote(default_offset)
        ) == unquote(expected)
      end
    end
  end

  describe "Is the last set of bytes to read?:" do
    parameters = [
      {30, 0, 5, false},
      {30, 27, 5, true},
      {30, 25, 5, true}
    ]
    for {file_size, current_read_bytes, default_offset, expected} <- parameters do
      test "with file_size=#{file_size} current_read_bytes=#{current_read_bytes} default_offset=#{default_offset}" do
        assert ReverseFile.last_read?(
          unquote(file_size), unquote(current_read_bytes), unquote(default_offset)
        ) == unquote(expected)
      end
    end
  end
end
