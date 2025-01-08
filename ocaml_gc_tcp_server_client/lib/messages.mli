open Ocaml_digestif_hash.Digital_signature_common

(** Message module defines the core messaging types and operations for the TCP server/client communication *)
module Message : sig
  (** Represents different types of messages in the system *)
  type msg_type =
    | Request   (** Client requests to server *)
    | Response  (** Server responses to client *)
    | Critical  (** Critical system messages *)
    | Info      (** Informational messages *)
    | Warning   (** Warning messages *)
    | Debug     (** Debug-level messages *)
    | Error     (** Error messages *)

  (** Represents a complete message structure with metadata and security features *)
  type message = {
    msg_type : msg_type;      (** Type of the message *)
    payload : string;         (** The actual message content *)
    timestamp : string;       (** Timestamp when the message was created *)
    hash : string;           (** Hash of the message contents for integrity verification *)
    signature : string option; (** Optional digital signature for message authenticity *)
  }

  (** Blake2b hash function implementation *)
  module Blak2b : HashFunction

  (** Converts a message type to its string representation *)
  val string_of_msg_type : msg_type -> string

  (** Converts a string to its corresponding message type *)
  val string_to_msg_type : string -> msg_type

  (** Serializes a message to string format for transmission *)
  val encode_message : message -> string

  (** Deserializes a string back into a message structure *)
  val decode_message : string -> message

  (** Computes a hash of the message using the specified hash function *)
  val hash_message : (module HashFunction) -> message -> string

  (** Signs a message using Ed25519 private key and specified hash function *)
  val sign_message :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.priv -> message -> message

  (** Verifies the signature of a message using Ed25519 public key *)
  val verify_signature :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.pub -> message -> bool
end
