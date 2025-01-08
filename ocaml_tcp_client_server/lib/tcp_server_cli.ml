open Lwt.Infix
open Cmdliner
open Ocaml_tcp_client_server

(* Sets up logging configuration using the Logs module
   - Configures formatter reporter for log output
   - Sets default log level to Info *)
let setup_logs () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info)

(* Main server startup function that:
   - Initializes logging
   - Creates a shutdown switch for graceful termination
   - Creates TCP socket and starts server
   - Returns Lwt unit after server is running *)
let start_server ip port () =
  setup_logs ();
  let shutdown_flag = Lwt_switch.create () in
  Tcp_server.TCP_Server.create_socket ip port >>= fun _ ->
  Tcp_server.TCP_Server.start_server ~ip ~port shutdown_flag >>= fun _ ->
  Logs_lwt.info (fun m -> m "TCP Server started on port %d" port) >>= fun () ->
  Lwt.return_unit

(* Command line argument definition for the start command
   - Defines --ip parameter with default "127.0.0.1"
   - Defines --port parameter with default 8080
   - Combines parameters into start_server function call wrapped in Lwt_main.run *)
let start_cmd =
  let ip =
    let doc = "IP address to bind the server." in
    Arg.(value & opt string "127.0.0.1" & info [ "ip" ] ~docv:"IP" ~doc)
  in
  let port =
    let doc = "Port number to listen on." in
    Arg.(value & opt int 8080 & info [ "port" ] ~docv:"PORT" ~doc)
  in
  Term.(
    const (fun ip port -> Lwt_main.run (start_server ip port ())) $ ip $ port)

(* Command metadata for the start subcommand *)
let start_info = Cmd.info "start" ~doc:"Start the TCP server"

(* Main CLI command configuration
   - Creates top-level command group
   - Adds start subcommand
   - Sets version and documentation *)
let cmd =
  let doc = "TCP server CLI" in
  let info = Cmd.info "tcp_server_cli" ~version:"v1.0" ~doc in
  Cmd.group info [ Cmd.v start_info start_cmd ]

(* Entry point that evaluates and executes the command *)
let () = exit (Cmd.eval cmd)
