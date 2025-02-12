open Lwt.Infix
open Ocaml_digestif_hash.Digital_signature_common

module TCP_Server : sig
  (* Interface defines a server with:
     - Configuration constants (max_clients)
     - Cryptographic keys for secure communication
     - Core server operations (create, start, stop)
  *)
  val max_clients : int
  val server_private_key : Digital_signature_common.private_key
  val server_public_key : Digital_signature_common.public_key
  val create_server : Unix.file_descr -> Lwt_switch.t -> unit -> unit Lwt.t
  val create_socket : string -> int -> Unix.file_descr Lwt.t

  val start_server :
    ?ip:string -> ?port:int -> Lwt_switch.t -> Unix.file_descr Lwt.t

  val stop_server : Lwt_switch.t -> Unix.file_descr -> unit Lwt.t
end = struct
  let max_clients = 10

  (* Private and public keys *)
  let server_private_key, server_public_key =
    Digital_signature_common.generate_keys ()

  let next_connection_id =
    let counter = ref 0 in
    fun () ->
      incr counter;
      !counter

  let rec handle_connection ic oc connection_id () =
    Lwt_io.read_line_opt ic >>= function
    | None ->
        Logs_lwt.info (fun m ->
            m "[connection: %i] Connection closed" connection_id)
        >>= fun () -> Lwt_io.close oc
    | Some encoded_msg -> (
        try
          let message = Messages.Message.decode_message encoded_msg in
          Logs_lwt.info (fun m ->
              m "[connection: %i] Received message of type: %s with payload: %s"
                connection_id
                (Messages.Message.string_of_msg_type message.msg_type)
                message.payload)
          >>= fun () ->
          (* Here we can process the message or send a message *)
          let response_msg =
            {
              message with
              msg_type = Messages.Message.Response;
              payload = "Acknowledge: " ^ message.payload;
            }
          in
          let encoded_response = Messages.Message.encode_message response_msg in
          Lwt_io.write_line oc encoded_response
          >>= handle_connection ic oc connection_id
        with
        | Errors.MessageError err ->
            Logs_lwt.err (fun m ->
                m "[connection: %i] Error decoding message: %s" connection_id
                  err)
        | exn ->
            Logs_lwt.err (fun m ->
                m "[connection: %i] Unexpected error: %s" connection_id
                  (Printexc.to_string exn))
            >>= fun () -> Lwt_io.close oc)

  let process_message received_msg =
    (* Handles different message types (Request, Critical, Info, etc.)
       - Creates appropriate responses based on message type
       - Adds timestamps and hashes to responses
       - Logs critical/warning/error messages
       - Returns a signed response message

       Could be improved by:
       - Extracting common response creation logic to reduce duplication
       - Adding message validation
       - Implementing proper error handling for invalid messages
    *)
    let open Messages.Message in
    match received_msg.msg_type with
    | Request ->
        let response_payload = "Process request: " ^ received_msg.payload in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Lwt.return response_msg
    | Critical ->
        let response_payload =
          "Critical message received, taking action: " ^ received_msg.payload
        in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Logs_lwt.warn (fun m ->
            m "Critical message processed: %s" response_msg.payload)
        >>= fun () -> Lwt.return response_msg
    | Info ->
        let response_payload = "Info acknowledge: " ^ received_msg.payload in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Lwt.return response_msg
    | Warning ->
        let response_payload = "Warning noted: " ^ received_msg.payload in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Logs_lwt.warn (fun m ->
            m "Warning message processed: %s" response_msg.payload)
        >>= fun () -> Lwt.return response_msg
    | Debug ->
        let response_payload = "Debug infoe type: " ^ received_msg.payload in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Lwt.return response_msg
    | Error ->
        let response_payload = "Error message type: " ^ received_msg.payload in
        let response_msg =
          {
            msg_type = Response;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Logs_lwt.err (fun m ->
            m "Error message processed: %s" response_msg.payload)
        >>= fun () -> Lwt.return response_msg
    | _ ->
        (* Handle unknown or unsupported message types *)
        let response_payload =
          "Unknown message type: " ^ received_msg.payload
        in
        let response_msg =
          {
            msg_type = Error;
            payload = response_payload;
            timestamp = string_of_float (Unix.time ());
            hash = "";
            signature = None;
          }
        in
        let hash = hash_message (module Blak2b) response_msg in
        let response_msg = { received_msg with hash } in
        Logs_lwt.err (fun m -> m "Received unknown message type.") >>= fun () ->
        Lwt.return response_msg

  (* TODO: verify signature? currently server sign all message response , for
     the message receive from client, check if it has signed or not by verify
     the signature
  *)
  let transfer_messages ic oc connection_id =
    (* Manages bidirectional communication with a client:
       - Reads incoming messages
       - Processes messages through process_message
       - Signs responses with server's private key
       - Sends encoded responses back to client
       - Handles connection errors and disconnections

       Could be improved by:
       - Adding timeout handling
       - Implementing message queuing for better flow control
       - Adding rate limiting
    *)
    let rec transfer () =
      (* Read message from the client *)
      Lwt_io.read_line_opt ic >>= function
      | None ->
          Logs_lwt.info (fun m ->
              m "[connection: %i] Client disconnected" connection_id)
      | Some encoded_message -> (
          try
            let received_message =
              Messages.Message.decode_message encoded_message
            in
            Logs_lwt.info (fun m ->
                m
                  "[connection: %i] Received message of type: %s with payload: \
                   %s"
                  connection_id
                  (Messages.Message.string_of_msg_type received_message.msg_type)
                  received_message.payload)
            >>= fun () ->
            process_message received_message >>= fun response_msg ->
            (* Sign the response message *)
            let signed_response =
              Messages.Message.sign_message
                (module Messages.Message.Blak2b)
                server_private_key response_msg
            in
            let encoded_response =
              Messages.Message.encode_message signed_response
            in
            Lwt_io.write_line oc encoded_response >>= fun () ->
            Logs_lwt.info (fun m ->
                m "[connection: %i] >> Sent response: %s" connection_id
                  response_msg.payload)
            >>= fun () -> transfer ()
          with
          | Errors.MessageError err ->
              Logs_lwt.err (fun m ->
                  m "[connection: %i] Error decoding message: %s" connection_id
                    err)
          | exn ->
              Logs_lwt.err (fun m ->
                  m "[connection: %i] Unexpected error: %s" connection_id
                    (Printexc.to_string exn)))
    in
    Lwt.catch
      (fun () -> transfer ())
      (fun exn ->
        Logs_lwt.debug (fun m ->
            m "[connection: %i] Error transferring message: %s" connection_id
              (Printexc.to_string exn)))

  let accept_connection conn =
    let connection_id = next_connection_id () in
    let fd, _ = conn in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.input fd in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.output fd in
    Lwt.on_failure (handle_connection ic oc connection_id ()) (fun exn ->
        Lwt_io.printf "%s" (Printexc.to_string exn) |> ignore);
    Lwt.async (fun () -> transfer_messages ic oc connection_id);
    Logs_lwt.info (fun m ->
        m "[connection: %i] New connection established" connection_id)
    >>= Lwt.return

  let create_socket ip port =
    let socket_addr = Lwt_unix.ADDR_INET (Unix.inet_addr_of_string ip, port) in
    let server_socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
    Lwt_unix.setsockopt server_socket Lwt_unix.SO_REUSEADDR true;
    Logs_lwt.info (fun m -> m "Binding to %s:%d" ip port) >>= fun () ->
    Lwt_unix.bind server_socket socket_addr >>= fun () ->
    Lwt_unix.listen server_socket max_clients;
    Logs_lwt.info (fun m -> m "Listening on %s:%d" ip port) >>= fun () ->
    Lwt.return (Lwt_unix.unix_file_descr server_socket)

  let create_server server_socket shutdown_flag =
    (* Creates server instance that:
       - Accepts new connections
       - Handles graceful shutdown via shutdown_flag
       - Delegates connection handling to accept_connection

       Could be improved by:
       - Adding connection pooling
       - Implementing backpressure mechanisms
       - Adding health checks
    *)
    let rec serve () =
      Lwt_unix.accept
        (Lwt_unix.of_unix_file_descr ~blocking:false server_socket)
      >>= fun conn ->
      if Lwt_switch.is_on shutdown_flag then accept_connection conn >>= serve
      else Lwt.return_unit
    in
    serve

  let start_server ?(ip = "127.0.01") ?(port = 8080) shutdown_flag =
    (* Initializes and starts the server:
       - Sets up signal handling (ignores SIGPIPE)
       - Creates socket and binds to specified IP/port
       - Starts accepting connections asynchronously
       - Provides error handling for startup failures
    *)
    Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
    Lwt.catch
      (fun () ->
        create_socket ip port >>= fun server_socket ->
        Lwt.async (fun () -> create_server server_socket shutdown_flag ());
        Logs_lwt.info (fun m -> m "Server started on IP %s and port %d" ip port)
        >>= fun () -> Lwt.return server_socket)
      (fun exn ->
        Logs_lwt.err (fun m ->
            m "Error starting server on IP %s and port %d: %s" ip port
              (Printexc.to_string exn))
        >>= fun () -> Lwt.fail exn)

  let stop_server shutdown_flag server_socket =
    Logs_lwt.info (fun m -> m "Stopping the server...") >>= fun () ->
    Lwt_switch.turn_off shutdown_flag >>= fun () ->
    Tcp_common.safe_close server_socket >>= fun () ->
    Logs_lwt.info (fun m -> m "Server stopped.")
end
