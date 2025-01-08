open Alcotest
open Ocaml_gc_tcp_server_client
open Lwt.Infix

(*NOTE: This is already invoked in
    [ocaml_digestif_hash/digital_signature_common.ml] before the [generate()]
    function. Calling it again in this test is unnecessary, and doing so would
    cause the test to fail. You only need to manually seed the RNG by providing
    entropy to Fortuna as follows: let () = Mirage_crypto_rng_lwt.initialize
    (module Mirage_crypto_rng.Fortuna)*)

(* Kill port while running test to prevent it is still running.
   [sudo kill -9 port]

   [sudo lsof -i :8080]
*)

(* Configuration for the TCP server and client *)
let ip = "127.0.0.1"  (* Use localhost for testing *)
let port = 0          (* Port 0 lets the OS assign an available port dynamically *)

let test_start_client_server () =
  Lwt_main.run
    ( (* Start the TCP server and get the server socket *)
      Tcp_server.TCP_Server.start_server ~ip ~port () >>= fun server_socket ->

      (* Get the actual port number assigned by the OS *)
      let server_address = Lwt_unix.getsockname server_socket in
      let port =
        match server_address with
        | Lwt_unix.ADDR_INET (_, port) -> port
        | _ -> failwith "Unexpected server address"
      in

      (* Initialize client and establish connection to server using the assigned port *)
      Tcp_client.TCP_Client.start_client ~ip ~port () >>= fun _ ->

      (* Add small delay to simulate communication/interaction *)
      Lwt_unix.sleep 0.5 >>= fun () ->

      (* Cleanup: Stop client first to prevent server from using closed socket *)
      Tcp_client.TCP_Client.stop_client () >>= fun () ->

      (* Finally stop the server after client is properly closed *)
      Tcp_server.TCP_Server.stop_server server_socket () >>= fun () ->
      Lwt.return_unit )

(* Register and run the test suite *)
let () =
  run "TCP Client-Server Tests"
    [
      ( "Client-Server",
        [ test_case "Client start" `Quick test_start_client_server ] );
    ]
