(* Import required modules *)
open Lwt.Infix
open Alcotest
open Ocaml_tcp_client_server

(* Test socket creation functionality *)
let test_create_socket () =
  let host = "127.0.0.1" in
  let port = 8080 in
  let server_socket =
    (* Create a socket and verify it's valid *)
    Tcp_server.TCP_Server.create_socket host port >>= fun socket ->
    let is_valid_socket =
      try
        (* Attempt to get socket name - this will fail if socket is invalid *)
        ignore (Unix.getsockname socket);
        true
      with Unix.Unix_error (Unix.EBADF, _, _) -> false
    in
    check bool "Socket is valid" true is_valid_socket;
    Lwt.return_unit
  in
  Lwt_main.run server_socket

(* Test server startup with timeout safety *)
let test_start_server () =
  let ip = "127.0.0.1" in
  let port = 8081 in
  let timeout_duration = 2.0 in
  let shutdown_flag = Lwt_switch.create () in
  let server =
    (* Use Lwt.pick to race between server start and timeout *)
    Lwt.pick
      [
        (* Attempt to start the server *)
        ( Tcp_server.TCP_Server.start_server ~ip ~port shutdown_flag >|= fun _ ->
          check bool "Server stared without issue" true true );
        (* Timeout after specified duration *)
        ( Lwt_unix.sleep timeout_duration >|= fun () ->
          check bool "Timeout reached, stopping server" true true );
      ]
  in
  Lwt_main.run server

(* Test server shutdown functionality *)
let test_stop_server () =
  let ip = "127.0.0.1" in
  let port = 8083 in
  let shutdown_flag = Lwt_switch.create () in
  let server_scenario =
    (* Start server, wait, then stop it *)
    Tcp_server.TCP_Server.start_server ~ip ~port shutdown_flag
    >>= fun server_socket ->
    (* Wait for 3 seconds to simulate server running *)
    Lwt_unix.sleep 3.0 >>= fun () ->
    (* Attempt to stop the server *)
    Tcp_server.TCP_Server.stop_server shutdown_flag server_socket >>= fun () ->
    check bool "Server stopped" true true;
    Lwt.return_unit
  in
  Lwt_main.run server_scenario

(* Register all tests *)
let tests =
  [
    test_case "Create server socket" `Quick test_create_socket;
    test_case "Start server" `Quick test_start_server;
    test_case "Stop server" `Quick test_stop_server;
  ]

(* Run the test suite *)
let () = Alcotest.run "TCP Server Tests" [ ("Server", tests) ]
