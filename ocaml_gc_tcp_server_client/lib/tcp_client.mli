(** TCP Client module providing network communication functionality *)
module TCP_Client : sig
  (** [start_client ~ip ~port ()] initializes and starts a TCP client connection
      @param ip The IP address of the server to connect to
      @param port The port number to connect to
      @return A Lwt thread that resolves when the client is started *)
  val start_client : ip:string -> port:int -> unit -> unit Lwt.t

  (** [stop_client ()] gracefully terminates the client connection
      @return A Lwt thread that resolves when the client is stopped *)
  val stop_client : unit -> unit Lwt.t

  (** [client_send_message ~msg_type message] sends a message to the connected server
      @param msg_type The type of message being sent (defined in Messages.Message)
      @param message The content of the message to send
      @return A Lwt thread that resolves when the message is sent *)
  val client_send_message :
    msg_type:Messages.Message.msg_type -> string -> unit Lwt.t

  (** [client_status ()] retrieves the current status of the client connection
      @return A Lwt thread that resolves with the client status *)
  val client_status : unit -> unit Lwt.t
end
