module TCP_Client : sig
  (** [connect_to_server host port] establishes a TCP connection to the server
      at the specified [host] and [port].
      Returns a file descriptor for the connected socket.
      @param host The hostname or IP address of the server
      @param port The port number to connect to
      @return Promise of a connected socket file descriptor *)
  val connect_to_server : string -> int -> Lwt_unix.file_descr Lwt.t

  (** [send_message socket message] sends a string message to the server
      through the connected socket.
      @param socket The connected socket file descriptor
      @param message The string message to send
      @return Promise of unit indicating completion *)
  val send_message : Lwt_unix.file_descr -> string -> unit Lwt.t

  (** [receive_message socket] reads a message from the server through
      the connected socket.
      @param socket The connected socket file descriptor
      @return Promise of the received string message *)
  val receive_message : Lwt_unix.file_descr -> string Lwt.t

  (** [stop_client switch socket] gracefully shuts down the client connection.
      Closes the socket and performs cleanup.
      @param switch The Lwt switch used to control client lifecycle
      @param socket The socket file descriptor to close
      @return Promise of unit indicating completion *)
  val stop_client : Lwt_switch.t -> Unix.file_descr -> unit Lwt.t

  (** [start_client host port switch] initializes and starts a TCP client.
      Establishes connection and returns the connected socket.
      @param host The hostname or IP address of the server
      @param port The port number to connect to
      @param switch The Lwt switch for controlling client lifecycle
      @return Promise of the connected socket file descriptor *)
  val start_client : string -> int -> Lwt_switch.t -> Lwt_unix.file_descr Lwt.t
end
