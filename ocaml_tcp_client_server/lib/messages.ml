open Yojson.Safe
open Ocaml_digestif_hash.Digital_signature_common

module Message : sig
  type msg_type =
    | Request
    | Response
    | Critical
    | Info
    | Warning
    | Debug
    | Error

  type message = {
    msg_type : msg_type;
    payload : string;
    timestamp : string;
    hash : string;
    signature : string option;
  }

  module Blak2b : HashFunction

  val string_of_msg_type : msg_type -> string
  val string_to_msg_type : string -> msg_type
  val encode_message : message -> string
  val decode_message : string -> message
  val hash_message : (module HashFunction) -> message -> string

  val sign_message :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.priv -> message -> message

  val verify_signature :
    (module HashFunction) -> Mirage_crypto_ec.Ed25519.pub -> message -> bool
end = struct
  type msg_type =
    | Request
    | Response
    | Critical
    | Info
    | Warning
    | Debug
    | Error

  type message = {
    msg_type : msg_type;
    payload : string;
    timestamp : string;
    hash : string;
    signature : string option;
  }

  (* Converts a message type variant to its string representation
     @param msg The message type to convert
     @return String representation of the message type *)
  let string_of_msg_type msg =
    match msg with
    | Request -> "Request"
    | Response -> "Response"
    | Critical -> "Critical"
    | Info -> "Info"
    | Warning -> "Warning"
    | Debug -> "Debug"
    | Error -> "Error"

  (* Converts a string to a message type variant
     @param msg_str The string to convert
     @return Message type variant
     @raise MessageError if the string doesn't match any valid message type *)
  let string_to_msg_type msg_str =
    match msg_str with
    | "Request" -> Request
    | "Response" -> Response
    | "Critical" -> Critical
    | "Info" -> Info
    | "Warning" -> Warning
    | "Debug" -> Debug
    | "Error" -> Error
    | _ -> raise (Errors.MessageError ("Invalid message type: " ^ msg_str))

  (* Encodes a message into a Base64 string for transmission
     @param msg The message to encode
     @return Base64 encoded string representation of the message
     @raise MessageError if JSON encoding fails *)
  let encode_message msg =
    try
      let msg_type_str = string_of_msg_type msg.msg_type in
      let json =
        `Assoc
          [
            ("type", `String msg_type_str);
            ("payload", `String msg.payload);
            ("timestamp", `String msg.timestamp);
            ("hash", `String msg.hash);
            ("signature", `String (Option.value msg.signature ~default:""));
          ]
      in
      let json_str = to_string json in
      Base64.encode_string json_str
    with
    | Yojson.Json_error err ->
        raise (Errors.MessageError ("JSON encoding error: " ^ err))
    | exn ->
        raise
          (Errors.MessageError
             ("Unexpected error during message encoding: "
            ^ Printexc.to_string exn))

  (* Decodes a Base64 encoded string back into a message
     @param encoded_msg The Base64 encoded message string
     @return Decoded message
     @raise MessageError if JSON decoding fails or message format is invalid *)
  let decode_message encoded_msg =
    try
      let decoded_str = Base64.decode_exn encoded_msg in
      let json = from_string decoded_str in
      match json with
      | `Assoc fields ->
          let msg_type_str =
            Yojson.Safe.Util.to_string (List.assoc "type" fields)
          in
          let msg_type = string_to_msg_type msg_type_str in
          let payload = Util.to_string (List.assoc "payload" fields) in
          let timestamp = Util.to_string (List.assoc "timestamp" fields) in
          let hash = Util.to_string (List.assoc "hash" fields) in
          let signature =
            Util.to_string_option (List.assoc "signature" fields)
          in
          { msg_type; payload; timestamp; hash; signature }
      | _ -> raise (Errors.MessageError "Invalid message format")
    with
    | Yojson.Json_error msg ->
        raise (Errors.MessageError ("JSON decoding error: " ^ msg))
    | exn ->
        raise
          (Errors.MessageError
             ("Unknown error during message decoding: " ^ Printexc.to_string exn))

  (* Blake2b implementation of the HashFunction interface
     Used for message integrity verification *)
  module Blak2b : HashFunction = struct
    let digest_string s = Digestif.BLAKE2B.(digest_string s |> to_raw_string)
  end

  (* Generates a hash of the message using the provided hash function
     @param (module Hash) The hash function module to use
     @param msg The message to hash
     @return Hash string of the message contents *)
  let hash_message (module Hash : HashFunction) msg =
    let msg_type_str = string_of_msg_type msg.msg_type in
    let data_to_hash = msg_type_str ^ msg.payload ^ msg.timestamp in
    (* Use Blake2b hashing function from DigitalSignatureCommon *)
    Hash.digest_string data_to_hash

  (* Signs a message using Ed25519 digital signatures
     @param (module Hash) The hash function module to use
     @param private_key The Ed25519 private key for signing
     @param msg The message to sign
     @return New message with hash and signature fields populated
     @raise MessageError if signing fails *)
  let sign_message (module Hash : HashFunction) private_key msg =
    try
      (* First, hash the message using the specific hash function *)
      let hash = hash_message (module Hash) msg in
      (* Now sign the document (payload) using the hash function and private key *)
      let _, signature =
        Digital_signature_common.sign_document
          (module Hash)
          private_key msg.payload
      in
      (* Return the message with updated hash and signature *)
      { msg with hash; signature = Some signature }
    with _ -> raise (Errors.MessageError "Failed to sign the message")

  (* Verifies the signature on a message
     @param (module Hash) The hash function module to use
     @param public_key The Ed25519 public key for verification
     @param msg The message to verify
     @return true if signature is valid
     @raise MessageError if signature verification fails
     @return false if message has no signature *)
  let verify_signature (module Hash : HashFunction) public_key msg =
    match msg.signature with
    | None -> false (* If there is no signature, verification fails *)
    | Some signature ->
        (* Hash the message payload using the same hash function *)
        let hash = hash_message (module Hash) msg in
        (* Verify the signature using the public key and the hashed payload *)
        if
          Digital_signature_common.verify_signature
            (module Hash)
            public_key hash signature
        then true
        else raise (Errors.MessageError "Signature verification failed")
end
