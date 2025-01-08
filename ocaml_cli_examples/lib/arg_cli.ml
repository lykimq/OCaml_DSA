(* Basic greeting functions *)
let greet name = Printf.printf "Hello, %s\n" name
let goodbye name = Printf.printf "Goodbye, %s\n" name

(* Main argument parsing function *)
let parse_args () =
  (* Mutable references to store the action type and name *)
  let action = ref None in
  let name = ref "" in
  let usage_msg = "Usage: oasis_cli -g NAME | -b NAME" in

  (* Handler for the greet command *)
  let set_greet n =
    action := Some "greet";
    name := n
  in

  (* Handler for the goodbye command *)
  let set_goodbye n =
    action := Some "goodbye";
    name := n
  in

  (* Define command line arguments *)
  let args =
    [
      ("--g", Arg.String set_greet, "Greet the user with the specified name");
      ("--b", Arg.String set_goodbye, "Say goodbye to the specified name");
    ]
  in

  (* Parse the command line arguments *)
  Arg.parse args (fun _ -> ()) usage_msg;

  (* Execute the appropriate action based on the parsed arguments *)
  match !action with
  | Some "greet" -> greet !name
  | Some "goodbye" -> goodbye !name
  | _ -> Printf.eprintf "No action specified. Use -g or -b.\n"
