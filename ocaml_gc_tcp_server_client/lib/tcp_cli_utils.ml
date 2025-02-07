open Lwt.Infix

let default_ip = "127.0.0.1"
let default_port = 8080
let verbose = ref false

let log_verbose msg =
  if !verbose then Lwt_io.printl ("[VERBOSE] " ^ msg) else Lwt.return ()

let print_usage program_type =
  let usage_msg =
    match program_type with
    | "client" ->
        "Usage: ./tcp_client <start|send|sign|stop|status> [-ip <IP>] [-port \
         <Port>] [-v] [<args>]\n\n\
         Available commands:\n\
         start  - Start the client with optional IP and port (defaults to \
         localhost:8080).\n\
         send   - Send a message to the server. Usage: ./tcp_client send \
         <message_type> <message>.\n\
         sign   - Send a critical message. Usage: ./tcp_client sign \
         <message_type> <message>.\n\
         stop   - Stop the client.\n\
         status - Check the client's connection status.\n\n\
         Message types:\n\
         Request, Critical, Info, Warning, Debug, Error\n\n\
         Optional Arguments:\n\
         -ip <IP>     - Specify the IP address (default: 127.0.0.1).\n\
         -port <Port> - Specify the port (default: 8080).\n\
         -v           - Enable verbose mode (detailed logging).\n"
    | "server" ->
        "Usage: ./tcp_server <start|stop|status|connections> [-ip <IP>] [-port \
         <Port>] [-v]\n\n\
         Available commands:\n\
         start       - Start the server with optional IP and port (defaults to \
         localhost:8080).\n\
         stop        - Stop the server if it is running.\n\
         status      - Check the status of the server.\n\
         connections - View active client connections.\n\n\
         Optional Arguments:\n\
         -ip <IP>     - Specify the IP address to bind to (default: 127.0.0.1).\n\
         -port <Port> - Specify the port number to bind to (default: 8080).\n\
         -v           - Enable verbose mode (detailed logging).\n"
    | _ -> "Unknown program type"
  in
  Lwt_io.printl usage_msg

let parse_args program_type valid_commands =
  if Array.length Sys.argv < 2 then
    print_usage program_type >>= fun () -> Lwt.fail_with "No command provided"
  else
    let command = Sys.argv.(1) in
    let rec check_args i =
      if i >= Array.length Sys.argv then ()
      else
        match Sys.argv.(i) with
        | "-v" ->
            verbose := true;
            check_args (i + 1)
        | _ -> check_args (i + 1)
    in
    check_args 2;
    if List.mem command valid_commands then Lwt.return (command, Sys.argv)
    else
      print_usage program_type >>= fun () ->
      Lwt.fail_with ("Unknown command: " ^ command)

(* Extract IP address and port number from command line arguments
   @param args Command line arguments array
   @return (string * int) tuple containing (IP address, port number)

   Example:
   let (ip, port) = get_ip_port Sys.argv
   -> ("127.0.0.1", 8080) *)
let get_ip_port args =
  let rec aux i ip port =
    (* Recursively process arguments until array bounds are reached *)
    if i >= Array.length args then (ip, port)
    else
      match args.(i) with
      | "-ip" when i + 1 < Array.length args ->
          (* Process IP address flag and its value *)
          aux (i + 2) args.(i + 1) port
      | "-port" when i + 1 < Array.length args ->
          (* Process port flag and its value *)
          aux (i + 2) ip (int_of_string args.(i + 1))
      | "-v" ->
          (* Skip verbose flag without consuming additional arguments *)
          aux (i + 1) ip port
      | _ ->
          (* Skip unknown arguments *)
          aux (i + 1) ip port
  in
  aux 2 default_ip default_port
