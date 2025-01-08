(* Import the Cmdliner module for building command-line interfaces *)
open Cmdliner

(* Simple greeting function that prints a hello message *)
let greet name = Printf.printf "Hello, %s\n" name

(* Define the command info for the 'input' subcommand *)
let start_info = Cmd.info "input" ~doc:"CLI example"

(* Define the main command structure *)
let start_cmd =
  (* Define a required positional argument for the name
     - pos 0: first position
     - some string: optional string that will be made required
     - None: default value
     - docv: placeholder name in documentation
     - doc: help text for the argument *)
  let name_arg =
    let doc = "The name of the person to greet." in
    Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME" ~doc)
  in
  (* Combine the greet function with the name argument *)
  Term.(const greet $ name_arg)

(* Create the main command group *)
let cmd =
  (* Define the top-level command info *)
  let info = Cmd.info "cli_example" ~doc:"A simple CLI example." in
  (* Create a command group with the 'input' subcommand *)
  Cmd.group info [ Cmd.v start_info start_cmd ]

(* Entry point: evaluate the command and use the result as exit code *)
let () = exit (Cmd.eval cmd)
