(* Open Lwt's infix operators for monadic operations *)
open Lwt.Infix

(* Common utility functions for both server and client CLI *)

(* Default connection settings *)
let default_ip = "127.0.0.1"
let default_port = 8080
let verbose = ref false

(* Helper function to log messages when verbose mode is enabled
   @param msg The message to log
   @return Lwt unit promise *)
let log_verbose msg =
  if !verbose then Lwt_io.printl ("[VERBOSE] " ^ msg) else Lwt.return ()

(* Extract IP and port from command line arguments
   @param args Command line arguments array
   @return tuple of (ip_address, port)

   Supports the following flags:
   -ip <address>   : Set IP address
   -port <number>  : Set port number
   -v             : Enable verbose mode *)
let get_ip_port args =
  let rec aux i ip port =
    if i >= Array.length args then (ip, port)
    else
      match args.(i) with
      | "-ip" when i + 1 < Array.length args -> aux (i + 2) args.(i + 1) port
      | "-port" when i + 1 < Array.length args ->
          aux (i + 2) ip (int_of_string args.(i + 1))
      | "-v" ->
          verbose := true;
          aux (i + 1) ip port
      | _ -> aux (i + 1) ip port
  in
  aux 2 default_ip default_port

(* Print usage instructions for the program
   @param program_type Either "client" or "server"
   @return Lwt unit promise with usage message *)
let print_usage program_type =
  let usage_msg =
    match program_type with
    | "client" ->
        "Usage: ./tcp_client_cli <start|send|stop> [-ip <IP>] [-port <Port>] [-v] [<args>]\n\n\
         Available commands:\n\
         start  - Start the client with optional IP and port (defaults to \
         localhost:8080).\n\
         send   - Send a message to the server. Usage: ./tcp_client send \
         <message_type> <message>.\n\
         stop   - Stop the client.\n\
         Message types:\n\
         Request, Critical, Info, Warning, Debug, Error\n\n\
         Optional Arguments:\n\
         -ip <IP>     - Specify the IP address (default: 127.0.0.1).\n\
         -port <Port> - Specify the port (default: 8080).\n\
         -v           - Enable verbose mode (detailed logging).\n"
    | "server" ->
        "Usage: ./tcp_server_cli <start|stop> [-ip <IP>] [-port <Port>] [-v]\n\n\
         Available commands:\n\
         start       - Start the server with optional IP and port (defaults to \
         localhost:8080).\n\
         stop        - Stop the server if it is running.\n\n\
         Optional Arguments:\n\
         -ip <IP>     - Specify the IP address to bind to (default: 127.0.0.1).\n\
         -port <Port> - Specify the port number to bind to (default: 8080).\n\
         -v           - Enable verbose mode (detailed logging).\n"
    | _ -> "Unknown program type"
  in
  Lwt_io.printl usage_msg

(* Parse and validate command line arguments
   @param program_type Either "client" or "server"
   @param valid_commands List of valid commands for the program
   @return Lwt promise containing tuple of (command, argv) or fails with error *)
let parse_args program_type valid_commands =
  if Array.length Sys.argv < 2 then
    print_usage program_type >>= fun () -> Lwt.fail_with "No command provided"
  else
    let command = Sys.argv.(1) in
    if List.mem command valid_commands then Lwt.return (command, Sys.argv)
    else
      print_usage program_type >>= fun () ->
      Lwt.fail_with ("Unknown command: " ^ command)
