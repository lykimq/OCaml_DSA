open Lwt.Infix
open Ocaml_digestif_hash.Digital_signature_common

module TCP_Server : sig
  val start_server :
    ?ip:string -> ?port:int -> unit -> Lwt_unix.file_descr Lwt.t

  val server_receive_messages : Lwt_unix.file_descr -> unit Lwt.t
  val stop_server : Lwt_unix.file_descr -> unit -> unit Lwt.t
  val get_active_connections : unit -> (Lwt_unix.file_descr * string) list
  val server_status : unit -> unit Lwt.t
end = struct
  (* Configuration and state management *)
  let max_clients = 10  (* Maximum concurrent connections allowed *)
  let connected_clients = ref 0  (* Counter for active connections *)
  let shutdown_flag = ref false  (* Controls server shutdown *)
  let client_sockets = Hashtbl.create 100  (* Tracks active client connections *)

  (* Cryptographic setup for secure communication *)
  let server_private_key, server_public_key =
    Digital_signature_common.generate_keys ()
  let client_public_key_ref = ref None

  (* Client connection management *)
  let add_client client_socket client_addr =
    let client_ip =
      match client_addr with
      | Lwt_unix.ADDR_INET (addr, _) -> Unix.string_of_inet_addr addr
      | _ -> "Unknown"
    in
    Hashtbl.add client_sockets client_socket client_ip;
    incr connected_clients;
    Lwt_io.printf "Client connected: %s\n" client_ip

  let client_disconnected = Hashtbl.create 100

  let mark_client_disconnected client_socket =
    Hashtbl.replace client_disconnected client_socket true;
    (* Get the peer name and log the disconnection message *)
    match Lwt_unix.getpeername client_socket with
    | Unix.ADDR_INET (inet_addr, _) ->
        log_attemp Logs.Level.INFO
          (Printf.sprintf "Client %s marked as disconnected"
             (Unix.string_of_inet_addr inet_addr))
    | Unix.ADDR_UNIX _ ->
        log_attemp Logs.Level.INFO
          "Client using Unix domain socket marked as disconnected"

  (* Clean up resources after a client disconnects and notify the server *)
  let cleanup_resources client_socket input_channel output_channel =
    Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
    let close_input () =
      Lwt.catch
        (fun () -> Lwt_io.close input_channel)
        (function
          | Unix.Unix_error (Unix.EBADF, _, _) ->
              log_attemp Logs.Level.ERROR
                "EBADF error: Ignoring bad file descriptor"
              >>= fun () -> Lwt.return_unit
          | exn ->
              log_attemp Logs.Level.ERROR
                ("Failed to close input channel: " ^ Printexc.to_string exn)
              >>= fun () -> Lwt.return_unit)
    in
    let close_output () =
      Lwt.catch
        (fun () -> Lwt_io.close output_channel)
        (function
          | Unix.Unix_error (Unix.EBADF, _, _) ->
              log_attemp Logs.Level.ERROR
                "EBADF error: Ignoring bad file descriptor"
              >>= fun () -> Lwt.return_unit
          | exn ->
              log_attemp Logs.Level.ERROR
                ("Failed to close output channel: " ^ Printexc.to_string exn)
              >>= fun () -> Lwt.return_unit)
    in
    let close_socket () =
      Lwt.catch
        (fun () -> Lwt_unix.close client_socket)
        (function
          | Unix.Unix_error (Unix.EBADF, _, _) ->
              log_attemp Logs.Level.ERROR
                "EBADF error: Ignoring bad file descriptor"
              >>= fun () -> Lwt.return_unit
          | exn ->
              log_attemp Logs.Level.ERROR
                ("Failed to close socket: " ^ Printexc.to_string exn)
              >>= fun () -> Lwt.return_unit)
    in
    mark_client_disconnected client_socket >>= fun () ->
    (* Remove client from the hash table and decrease the count *)
    (*Hashtbl.remove client_sockets client_socket;*
      decr connected_clients;

      (* Notify that a client slot is free now *)
      Lwt_condition.signal client_disconnect_condition ();*)

    (* Explicitly close channels and socket to release resources *)
    close_input () >>= fun () ->
    close_output () >>= fun () ->
    close_socket () >>= fun () ->
    log_attemp Logs.Level.INFO
      "Cleaned up resources and closed client connection."

  (* Handshake protocol implementation *)
  let server_handshake ?(attempts = 3) client_socket =
    let client_ip = Hashtbl.find_opt client_sockets client_socket in
    let input_channel = Lwt_io.of_fd ~mode:Lwt_io.input client_socket in
    let output_channel = Lwt_io.of_fd ~mode:Lwt_io.output client_socket in
    let rec attempt_handshake remaining_attempts =
      if remaining_attempts = 0 || !shutdown_flag then
        Lwt.fail_with "Server is shutting down, handshake aborted."
      else
        log_attemp Logs.Level.INFO
          (Printf.sprintf "Starting handshake with client: %s"
             (Option.value ~default:"Unknown" client_ip))
        >>= fun () ->
        Lwt.catch
          (fun () ->
            (* Receive client's public key *)
            Lwt_io.read_line_opt input_channel >>= function
            | None ->
                log_attemp Logs.Level.ERROR
                  (Printf.sprintf "Client %s disconnected during handshake.\n"
                     (Option.value ~default:"Unknown" client_ip))
                >>= fun () ->
                (*cleanup_resources client_socket input_channel output_channel
                  >>= fun () ->*)
                Lwt.fail
                  (Errors.ConnectionError "Client disconnected during handshake")
            | Some client_public_key_str -> (
                match
                  Mirage_crypto_ec.Ed25519.pub_of_octets client_public_key_str
                with
                | Ok client_public_key ->
                    client_public_key_ref := Some client_public_key;
                    log_attemp Logs.Level.INFO
                      (Printf.sprintf "Received client public key from %s.\n"
                         (Option.value ~default:"Unknown" client_ip))
                    >>= fun () ->
                    (* Send server's public key to the client *)
                    let server_public_key_str =
                      Mirage_crypto_ec.Ed25519.pub_to_octets server_public_key
                    in
                    Lwt_io.write_line output_channel server_public_key_str
                    >>= fun () ->
                    log_attemp Logs.Level.INFO
                      (Printf.sprintf "Sent server public key to client %s."
                         (Option.value ~default:"Unknown" client_ip))
                    >>= fun () -> Lwt.return_unit
                | Error _ ->
                    log_attemp Logs.Level.ERROR
                      (Printf.sprintf
                         "Failed to deserialize client public key from %s."
                         (Option.value ~default:"Unknown" client_ip))
                    >>= fun () ->
                    cleanup_resources client_socket input_channel output_channel
                    >>= fun () ->
                    Lwt.fail
                      (Errors.MessageError "Invalid client public key format.")))
          (fun exn ->
            log_attemp Logs.Level.ERROR
              (Printf.sprintf "Handshake failed for client %s: %s\n"
                 (Option.value ~default:"Unknown" client_ip)
                 (Printexc.to_string exn))
            >>= fun () ->
            log_attemp Logs.Level.INFO "Retrying handshake..." >>= fun () ->
            Lwt_unix.sleep 1.0 >>= fun () ->
            attempt_handshake (remaining_attempts - 1))
    in
    attempt_handshake attempts

  (* Message processing pipeline *)
  let process_message message_str output_channel client_socket =
    if Hashtbl.find_opt client_disconnected client_socket = Some true then
      Lwt.return_unit
    else
      Lwt.catch
        (fun () ->
          let client_ip = Hashtbl.find_opt client_sockets client_socket in
          let open Messages.Message in
          (* Decode and process the message *)
          let message = decode_message message_str in
          log_attemp Logs.Level.INFO
            (Printf.sprintf "Processing message from %s:%s"
               (Option.value ~default:"Unknown" client_ip)
               message.payload)
          >>= fun () ->
          (* Verify the client message if it is signed *)
          match (message.signature, !client_public_key_ref) with
          | Some _, Some client_public_key ->
              if verify_signature (module Blak2b) client_public_key message then
                log_attemp Logs.Level.INFO
                  (Printf.sprintf
                     "Signature verificaiton successful for client %s.\n"
                     (Option.value ~default:"Unknown" client_ip))
                >>= fun () ->
                log_attemp Logs.Level.INFO
                  ("Received message : %s\n" ^ message.payload)
                >>= fun () ->
                let response_message =
                  {
                    msg_type = Response;
                    payload = "Acknowledge " ^ message.payload;
                    timestamp = string_of_float (Unix.time ());
                    hash = "";
                    signature = None;
                  }
                in
                let response_message_hash =
                  hash_message (module Blak2b) response_message
                in
                let response_message =
                  { response_message with hash = response_message_hash }
                in
                let signed_response =
                  match response_message.msg_type with
                  | Critical ->
                      sign_message
                        (module Blak2b)
                        server_private_key response_message
                  | _ -> response_message
                in
                let encoded_message = encode_message signed_response in
                if
                  Hashtbl.find_opt client_disconnected client_socket = Some true
                then Lwt.return_unit
                else
                  (* Send the encoded response back to the client *)
                  Lwt_io.write_line output_channel encoded_message
              else
                log_attemp Logs.Level.ERROR
                  (Printf.sprintf "Invalid signature from client %s."
                     (Option.value ~default:"Unknown" client_ip))
                >>= fun () ->
                Lwt.fail (Errors.MessageError "Invalid client signature")
          | None, _ ->
              log_attemp Logs.Level.INFO "Message is not signed.\n"
              >>= fun () -> Lwt.return_unit
          | _, None ->
              log_attemp Logs.Level.ERROR
                (Printf.sprintf "No client public key available for client %s"
                   (Option.value ~default:"Unknown" client_ip))
              >>= fun () -> Lwt.fail_with "No client public key available.")
        (function
          | Unix.Unix_error (Unix.EBADF, _, _) ->
              log_attemp Logs.Level.ERROR
                "EBADF error in process_message: Ignoring"
              >>= fun () -> Lwt.return_unit
          | exn ->
              log_attemp Logs.Level.ERROR
                ("Error in process_message: " ^ Printexc.to_string exn)
              >>= fun () -> Lwt.fail exn)

  let received_message_with_timeout input_channel timeout_duration =
    Lwt_unix.with_timeout timeout_duration (fun () ->
        Lwt_io.read_line_opt input_channel)

  (* Main server loop *)
  let rec accept_clients server_socket =
    if !shutdown_flag then
      Lwt_io.printf "Server is shutting down, no new connections.\n"
    else if !connected_clients >= max_clients then
      handle_max_clients server_socket
    else
      (* Accept new incoming connections *)
      Lwt_unix.accept server_socket >>= fun (client_socket, client_addr) ->
      if !shutdown_flag then
        (* If shutdown started after accepting, immediately reject *)
        Lwt_io.printf "Rejecting connection due to server shutdown.\n"
        >>= fun () -> Lwt_unix.close client_socket
      else
        add_client client_socket client_addr >>= fun () ->
        (* Lauch client handling in an asynchronous task *)
        Lwt.async (fun () -> handle_client client_socket);
        (* Continue accepting new clients *)
        accept_clients server_socket

  (* Server lifecycle management *)
  let start_server ?(ip = "127.0.0.1") ?(port = 8080) () =
    if !shutdown_flag then
      log_attemp Logs.Level.ERROR "Sever is shutting down, cannot start"
      >>= fun () -> Lwt.fail_with "Server is shutting down, cannot start"
    else
      log_attemp Logs.Level.INFO
        (Printf.sprintf "Starting server on %s:%d" ip port)
      >>= fun () ->
      Lwt.catch
        (fun () ->
          create_server_socket ip port >>= fun server_socket ->
          Lwt.async (fun () -> accept_clients server_socket);
          Lwt.return server_socket)
        (fun exn ->
          log_attemp Logs.Level.ERROR
            ("Server start error: " ^ Printexc.to_string exn)
          >>= fun () ->
          Lwt.fail
            (Errors.ConnectionError
               ("Server start error: " ^ Printexc.to_string exn)))

  (* Stop the server and close all connections *)
  let stop_server server_socket () =
    log_attemp Logs.Level.INFO "Disconneting server" >>= fun () ->
    shutdown_flag := true;
    (* Close the listening socket to stop accepting new connections *)
    Lwt_unix.close server_socket >>= fun () ->
    log_attemp Logs.Level.INFO
      "Server socket closed, no new connection will be accepted."
    >>= fun () ->
    (* Wait for active clients to finish their work *)
    let rec wait_for_clients () =
      if !connected_clients > 0 then
        log_attemp Logs.Level.INFO
          (Printf.sprintf "Waiting for %d active client(s) to disconnect..."
             !connected_clients)
        >>= fun () ->
        (* Wait for a client to disconnect, then check again *)
        Lwt_condition.wait client_disconnect_condition >>= fun () ->
        wait_for_clients ()
      else Lwt.return_unit
    in

    wait_for_clients () >>= fun () ->
    (* Close all active client connections *)
    let close_client_sockets () =
      Hashtbl.fold
        (fun client_socket _ acc ->
          acc >>= fun () ->
          log_attemp Logs.Level.INFO "Closing connection for a client...\n"
          >>= fun () -> Lwt_unix.close client_socket)
        client_sockets Lwt.return_unit
    in
    close_client_sockets () >>= fun () ->
    (* Clear the client sockets hash table *)
    Hashtbl.reset client_sockets;
    log_attemp Logs.Level.INFO "Server stopped.\n"

  let get_active_connections () =
    Hashtbl.fold
      (fun client_socket client_ip acc -> (client_socket, client_ip) :: acc)
      client_sockets []

  (* Check the status of the server *)
  let server_status () =
    let client_count = Hashtbl.length client_sockets in
    log_attemp Logs.Level.INFO
      (Printf.sprintf "Active connections: %d\n" client_count)
    >>= fun () ->
    if client_count > 0 then
      log_attemp Logs.Level.INFO "Server Status:\n" >>= fun () ->
      Hashtbl.fold
        (fun _ client_ip acc ->
          acc >>= fun () -> Lwt_io.printf "Client: %s\n" client_ip)
        client_sockets Lwt.return_unit
    else log_attemp Logs.Level.INFO "No active connections.\n"
end
