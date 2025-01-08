open Lwt.Infix

module TCP_Client : sig
  (* Establishes a connection to a TCP server at the specified host and port *)
  val connect_to_server : string -> int -> Lwt_unix.file_descr Lwt.t
  (* Sends a string message to the connected server *)
  val send_message : Lwt_unix.file_descr -> string -> unit Lwt.t
  (* Receives a string message from the connected server *)
  val receive_message : Lwt_unix.file_descr -> string Lwt.t
  (* Gracefully stops the client and closes the connection *)
  val stop_client : Lwt_switch.t -> Unix.file_descr -> unit Lwt.t
  (* Initializes and starts the client, setting up message handling loop *)
  val start_client : string -> int -> Lwt_switch.t -> Lwt_unix.file_descr Lwt.t
end = struct
  (* Creates a TCP socket and connects to the specified server
     @param host The server's IP address or hostname
     @param port The server's port number
     @return A promise of the connected socket file descriptor *)
  let connect_to_server host port =
    let addr = Unix.ADDR_INET (Unix.inet_addr_of_string host, port) in
    let client_socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
    Lwt_unix.connect client_socket addr >>= fun () ->
    Logs_lwt.info (fun m -> m "Client connected to server on port %d" port)
    >>= fun () -> Lwt.return client_socket

  (* Sends a message to the server through the connected socket
     @param client_socket The connected socket file descriptor
     @param message The string message to send
     @return A promise that resolves when the message is sent *)
  let send_message client_socket message =
    let oc = Lwt_io.of_fd ~mode:Lwt_io.output client_socket in
    Lwt_io.write_line oc message >>= fun () ->
    Logs_lwt.info (fun m -> m "Message send: %s" message)

  (* Receives a message from the server
     @param client_socket The connected socket file descriptor
     @return A promise of the received message string
     @raises Fails with "No message received" if the server closes the connection *)
  let receive_message client_socket =
    let ic = Lwt_io.of_fd ~mode:Lwt_io.input client_socket in
    Lwt_io.read_line_opt ic >>= function
    | Some message ->
        Logs_lwt.info (fun m -> m "Message received: %s" message) >>= fun () ->
        Lwt.return message
    | None -> Lwt.fail_with "No message received"

  (* Gracefully stops the client by turning off the shutdown flag and closing the socket
     @param shutdown_flag The switch used to control client shutdown
     @param client_socket The socket to close
     @return A promise that resolves when the client is stopped *)
  let stop_client shutdown_flag client_socket =
    Logs_lwt.info (fun m -> m "Stopping client...") >>= fun () ->
    Lwt_switch.turn_off shutdown_flag >>= fun () ->
    Tcp_common.safe_close client_socket >>= fun () ->
    Logs_lwt.info (fun m -> m "Client stopped.")

  (* Starts the client and establishes a message handling loop
     @param host The server's IP address or hostname
     @param port The server's port number
     @param shutdown_flag The switch used to control client shutdown
     @return A promise of the connected socket file descriptor

     The function:
     1. Connects to the server
     2. Starts an asynchronous loop that:
        - Receives messages from the server
        - Sends replies back
        - Handles errors and connection closures
     3. Returns the connected socket for further management *)
  let start_client host port shutdown_flag =
    connect_to_server host port >>= fun client_socket ->
    let rec client_loop () =
      if Lwt_switch.is_on shutdown_flag then
        (* If the shutdown flag is turned on, stop the loop *)
        Logs_lwt.info (fun m -> m "Client shutdown initiated; exiting loop.")
      else
        Lwt.catch
          (fun () ->
            (* Try to receive a message from the server *)
            receive_message client_socket >>= fun message ->
            Logs_lwt.info (fun m -> m "Received message: %s" message)
            >>= fun () ->
            (* Send a reply to the server *)
            send_message client_socket ("Reply: " ^ message) >>= fun () ->
            (* Continue the loop unless the shutdown flag is on *)
            client_loop ())
          (function
            | Unix.Unix_error (Unix.EBADF, _, _) ->
                Logs_lwt.err (fun m ->
                    m "Socket closed or invalid; exiting loop.")
                >>= fun () ->
                Lwt.return_unit (* Exit loop when socket is closed *)
            | exn ->
                Logs_lwt.err (fun m ->
                    m "Error in client loop: %s" (Printexc.to_string exn))
                >>= fun () -> Lwt.return_unit (* Exit loop on error *))
    in
    (* Run the client loop asynchronously *)
    Lwt.async (fun () -> client_loop ());

    (* Hook the shutdown flag to stop the client gracefully *)
    (*Lwt_switch.add_hook (Some shutdown_flag) (fun () ->
        Logs_lwt.info (fun m -> m "Shutting down client...") >>= fun () ->
        stop_client shutdown_flag (Lwt_unix.unix_file_descr client_socket));*)
    Logs_lwt.info (fun m -> m "Client started.") >>= fun () ->
    Lwt.return client_socket
end
