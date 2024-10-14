# Reverse file

This is a mini project to reverse a file line by line using Elixir/Erlang.

Also, it is used the low level OS calls which handle the position of the internal pointer that OS keep for each opened file.

## Test files

Sorted by size:

| file name | lines | size |
| --------- | ----- | ---- |
| logs/example.log | 5 | 30B |
| logs/boot.log | 110 | 9.7KB |
| logs/Zookeeper.log | 74380 | 10M |
| logs/HPC.log | 433489 | 34MB |

## Build

    mix escript.build

This command generates an "cli" executable file.

## Run

    ./cli --path <path> --offset <default_offset>

* <path> is a file path, where the file we want to reverse is placed.
* <default_offset> is a parameter to optimize read of files. Play with it!
