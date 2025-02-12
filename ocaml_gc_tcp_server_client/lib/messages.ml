open Yojson.Safe
open Ocaml_digestif_hash.Digital_signature_common

module Message : sig
  (* Message types represent different categories of communication between
     client and server. Each type serves a specific purpose in the system. *)
  type msg_type =
    | Request
    (* A message requesting an action or data, typically sent form a client to a
       server. Example: HTTP GET or POST request.
    *)
    | Response
    (* A message sent in response to a request, containing the result of the
       result of the requested action or data. Example: HTTP 200 OK response or
       an error message in reponse to a request.
    *)
    | Critical
    (* A high-priority message indicating an urgent or critical situation
       request immediate action. Example: System alerts or notifications about
       security breaches or critical systems failure. *)
    | Info
    (* An information message that does not require immdiate action, often used
       for status updates, logs, or notifications. Example: Regular system logs
       or status reports on successful operations. *)
    | Warning
    (* A message that indicates a potential problem or situation that may
       require attention but is not immediately critical. Example: Low disk
       space warning or high memory usage alert. *)
    | Debug
    (* A message used for debugging purposes, providing detailed information
       about the system's internal state. *)
    | Error
  (* A message indicating that an error has occurred, typically including
     details about the failure. Example: HTTP 500 Internal Server Error or a
     custom error message explaining when went wrong. *)

  (* Core message structure containing all necessary fields for secure communication *)
  type message = {
    msg_type : msg_type;
    payload : string;  (* The actual message content *)
    timestamp : string; (* Timestamp for message ordering and validation *)
    hash : string;     (* Cryptographic hash for message integrity *)
    signature : string option; (* Digital signature for authentication *)
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
  (* Define the message type *)

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
    payload : string; (* The actual message content *)
    timestamp : string; (* Timestamp when the message was created *)
    hash : string; (* Hash of the message contents *)
    signature : string option; (* Optional digital signature for authenticity *)
  }

  (* Converts a message type to its string representation for serialization *)
  let string_of_msg_type msg =
    match msg with
    | Request -> "Request"
    | Response -> "Response"
    | Critical -> "Critical"
    | Info -> "Info"
    | Warning -> "Warning"
    | Debug -> "Debug"
    | Error -> "Error"

  (* Safely converts a string back to a message type, raising an error for invalid types *)
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

  (* Serializes a message to JSON and encodes it in Base64 for safe transmission
     This ensures the message can be safely transmitted over any channel *)
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

  (* Decodes a Base64 encoded message and reconstructs the original message structure
     Performs validation and error checking during the decoding process *)
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

  (* Blake2b implementation for secure cryptographic hashing *)
  module Blak2b : HashFunction = struct
    (* Uses Blake2b algorithm for consistent and secure message hashing *)
    let digest_string s = Digestif.BLAKE2B.(digest_string s |> to_raw_string)
  end

  (* Creates a cryptographic hash of the message contents for integrity verification
     Combines message type, payload, and timestamp to create a unique hash *)
  let hash_message (module Hash : HashFunction) msg =
    let msg_type_str = string_of_msg_type msg.msg_type in
    let data_to_hash = msg_type_str ^ msg.payload ^ msg.timestamp in
    (* Use Blake2b hashing function from DigitalSignatureCommon *)
    Hash.digest_string data_to_hash

  (* Signs a message using Ed25519 digital signatures
     Returns a new message with updated hash and signature fields *)
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

  (* Verifies the authenticity of a signed message using the sender's public key
     Returns true if signature is valid, raises an error if verification fails *)
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
