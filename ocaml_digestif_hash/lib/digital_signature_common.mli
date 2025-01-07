module type HashFunction = sig
  (* Takes a string input and returns its cryptographic hash as a string *)
  val digest_string : string -> string
end

module Digital_signature_common : sig
  (* Type definitions for digital signature operations *)
  type document = string    (* The content to be signed, represented as a string *)
  type signature = string   (* The cryptographic signature output *)
  type private_key = Mirage_crypto_ec.Ed25519.priv  (* Ed25519 private key for signing *)
  type public_key = Mirage_crypto_ec.Ed25519.pub    (* Ed25519 public key for verification *)

  (* Generates a new Ed25519 key pair for signing and verification
     Returns: (private_key * public_key) tuple *)
  val generate_keys : unit -> private_key * public_key

  (* Signs a document using Ed25519 with a specified hash function
     Parameters:
     - HashFunction module for document hashing
     - private_key for signing
     - document to sign
     Returns: (original_document * signature) tuple *)
  val sign_document :
    (module HashFunction) -> private_key -> document -> string * signature

  (* Verifies a signature using Ed25519 with a specified hash function
     Parameters:
     - HashFunction module (must match the one used for signing)
     - public_key corresponding to the private key used for signing
     - original document
     - signature to verify
     Returns: bool indicating if signature is valid *)
  val verify_signature :
    (module HashFunction) -> public_key -> document -> signature -> bool
end
