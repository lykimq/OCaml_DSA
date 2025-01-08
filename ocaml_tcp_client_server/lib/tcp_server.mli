open Ocaml_digestif_hash.Digital_signature_common

module TCP_Server : sig
  (** Maximum number of concurrent client connections allowed *)
  val max_clients : int

  (** Server's private key used for digital signatures and encryption *)
  val server_private_key : Digital_signature_common.private_key

  (** Server's public key shared with clients for verification *)
  val server_public_key : Digital_signature_common.public_key

  (** Creates and manages a TCP server instance
      @param socket The Unix file descriptor for the server socket
      @param switch Lwt switch for graceful shutdown control
      @param unit Unit parameter
      @return A Lwt thread managing the server lifecycle *)
  val create_server : Unix.file_descr -> Lwt_switch.t -> unit -> unit Lwt.t

  (** Creates a TCP socket bound to the specified address and port
      @param ip_address The IP address to bind to
      @param port The port number to listen on
      @return A Lwt thread containing the bound socket file descriptor *)
  val create_socket : string -> int -> Unix.file_descr Lwt.t

  (** Initializes and starts the TCP server
      @param ?ip Optional IP address (defaults to localhost)
      @param ?port Optional port number (defaults to system-chosen port)
      @param switch Lwt switch for server lifecycle control
      @return A Lwt thread containing the server socket file descriptor *)
  val start_server :
    ?ip:string -> ?port:int -> Lwt_switch.t -> Unix.file_descr Lwt.t

  (** Gracefully stops the TCP server
      @param switch Lwt switch to trigger shutdown
      @param socket The server socket to close
      @return A Lwt thread completing when the server has stopped *)
  val stop_server : Lwt_switch.t -> Unix.file_descr -> unit Lwt.t
end
