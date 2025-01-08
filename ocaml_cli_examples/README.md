# OCaml CLI Examples

This project demonstrates two different approaches to building command-line interfaces in OCaml: using the `Cmdliner` library and the built-in `Arg` module.

Features:
- Subcommand support
- Automatic help generation
- Type-safe argument parsing
- Built-in documentation support

## Project Structure Details

- `cmd_cli.ml`: Demonstrates a more robust CLI implementation using Cmdliner, with proper subcommand support and documentation.
- `arg_cli.ml`: Shows a simpler approach using the standard library's Arg module, suitable for basic CLI tools.
- `test_ocaml_cli_examples.ml`: Contains unit tests to verify the CLI behavior.
