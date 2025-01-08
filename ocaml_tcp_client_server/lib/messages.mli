open Ocaml_digestif_hash.Digital_signature_common

(** Message module defines the core message types and operations for the TCP client-server communication *)
module Message : sig
  (** Represents different types of messages that can be exchanged in the system *)
  type msg_type =
    | Request
    (** A message requesting an action or data, typically sent from a client to a
        server. Example: HTTP GET or POST request.
    *)
    | Response
    (** A message sent in response to a request, containing the result of the
        requested action or data. Example: HTTP 200 OK response or
        an error message in response to a request.
    *)
    | Critical
    (** A high-priority message indicating an urgent or critical situation
        requiring immediate action. Example: System alerts or notifications about
        security breaches or critical systems failure.
    *)
    | Info
    (** An informational message that does not require immediate action, often used
        for status updates, logs, or notifications. Example: Regular system logs
        or status reports on successful operations.
    *)
    | Warning
    (** A message that indicates a potential problem or situation that may
        require attention but is not immediately critical. Example: Low disk
        space warning or high memory usage alert.
    *)
    | Debug
    (** A message used for debugging purposes, providing detailed information
        about the system's internal state.
    *)
    | Error
    (** A message indicating that an error has occurred, typically including
        details about the failure. Example: HTTP 500 Internal Server Error or a
        custom error message explaining what went wrong.
    *)

  (** Represents a complete message with metadata and security features *)
  type message = {
    msg_type : msg_type;  (** Type of the message *)
    payload : string;     (** The actual message content *)
    timestamp : string;   (** Timestamp when the message was created *)
    hash : string;        (** Hash of the message contents for integrity verification *)
    signature : string option; (** Optional digital signature for authenticity verification *)
  }

  (** Blake2b hash function implementation module *)
  module Blak2b : HashFunction

  (** Converts a message type to its string representation *)
  val string_of_msg_type : msg_type -> string

  (** Converts a string representation back to a message type *)
  val string_to_msg_type : string -> msg_type

  (** Serializes a message into a string format for transmission *)
  val encode_message : message -> string

  (** Deserializes a string back into a message structure *)
  val decode_message : string -> message

  (** Computes a hash of the message using the specified hash function *)
  val hash_message : (module HashFunction) -> message -> string

  (** Signs a message using Ed25519 private key and specified hash function *)
  val sign_message :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.priv -> message -> message

  (** Verifies the signature of a message using Ed25519 public key and specified hash function *)
  val verify_signature :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.pub -> message -> bool
end
