open Lwt.Infix
open Tcp_cli_common
open Ocaml_tcp_client_server

(* Global state management *)
let client_socket_ref = ref None    (* Stores the active client socket *)
let shutdown_flag_ref = ref None    (* Stores the shutdown switch for graceful termination *)

(* Starts a TCP client connection
   - Prevents multiple client instances
   - Parses IP and port from arguments
   - Creates a shutdown switch for graceful termination
   - Initializes TCP client connection
   - Stores references for later use *)
let start_client () =
  match !client_socket_ref with
  | Some _ -> Logs_lwt.info (fun m -> m "Client is already running.\n")
  | None ->
      parse_args "client" [ "start" ] >>= fun (_, args) ->
      let ip, port = get_ip_port args in
      let shutdown_flag = Lwt_switch.create () in
      shutdown_flag_ref := Some shutdown_flag;
      Logs_lwt.info (fun m ->
          m "Starting TCP client to connect to %s:%d" ip port)
      >>= fun () ->
      Tcp_client.TCP_Client.start_client ip port shutdown_flag
      >>= fun client_socket ->
      client_socket_ref := Some client_socket;
      Logs_lwt.info (fun m -> m "Client started. Press Ctrl+C to stop.")

(* Stops the running TCP client
   - Checks for existing client and shutdown flag
   - Gracefully terminates the connection
   - Logs the operation status *)
let stop_client () =
  match (!client_socket_ref, !shutdown_flag_ref) with
  | Some client_socket, Some shutdown_flag ->
      Logs_lwt.info (fun m -> m "Stopping client...") >>= fun () ->
      Tcp_client.TCP_Client.stop_client shutdown_flag
        (Lwt_unix.unix_file_descr client_socket)
      >>= fun () -> Logs_lwt.info (fun m -> m "Client stopped.")
  | _ -> Logs_lwt.err (fun m -> m "No running client to stop.")

(* Sends a message through the active client connection
   - Validates command arguments (type and content)
   - Requires running client connection
   - Formats and sends the message *)
let send_message args =
  if Array.length args < 4 then
    Lwt_io.printl "Usage: ./tcp_client_cli send <message_type> <message>"
    >>= fun () -> Lwt.fail_with "Invalid arguments"
  else
    let message_type = args.(2) in
    let message = args.(3) in
    match !client_socket_ref with
    | Some client_socket ->
        Logs_lwt.info (fun m ->
            m "Sending message of type: %s with content: %s" message_type
              message)
        >>= fun () -> Tcp_client.TCP_Client.send_message client_socket message
    | None -> Logs_lwt.err (fun m -> m "Client not running.")

(* Main entry point that:
   - Defines valid commands (start/send/stop)
   - Parses and routes commands to appropriate handlers
   - Runs in Lwt event loop *)
let run () =
  let valid_commands = [ "start"; "send"; "stop" ] in
  Lwt_main.run
    ( parse_args "client" valid_commands >>= fun (command, args) ->
      match command with
      | "start" -> start_client ()
      | "send" -> send_message args
      | "stop" -> stop_client ()
      | _ -> failwith "Unknown command" )

let () = run ()
