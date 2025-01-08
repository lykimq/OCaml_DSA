module TCP_Server : sig
  (** Start a TCP server with optional IP and port configuration
      @param ip Optional IP address to bind to (defaults to localhost)
      @param port Optional port number to listen on (defaults to system-chosen port)
      @return A Lwt thread containing the server's file descriptor *)
  val start_server :
    ?ip:string -> ?port:int -> unit -> Lwt_unix.file_descr Lwt.t

  (** Handle incoming messages from clients
      @param file_descr The server's file descriptor
      @return A Lwt thread that processes incoming messages *)
  val server_receive_messages : Lwt_unix.file_descr -> unit Lwt.t

  (** Gracefully shutdown the server
      @param file_descr The server's file descriptor
      @param unit Unit parameter
      @return A Lwt thread that completes when the server is stopped *)
  val stop_server : Lwt_unix.file_descr -> unit -> unit Lwt.t

  (** Retrieve list of currently connected clients
      @return List of tuples containing client file descriptors and their addresses *)
  val get_active_connections : unit -> (Lwt_unix.file_descr * string) list

  (** Print current server status information
      @return A Lwt thread that completes after printing status *)
  val server_status : unit -> unit Lwt.t
end
