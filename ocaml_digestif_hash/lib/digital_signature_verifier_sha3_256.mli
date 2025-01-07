module DigitalSignatureVerifier : sig
  (** Digital signature implementation using Ed25519 and SHA3-256 *)

  (** {1 Type Definitions} *)

  type document = string
  (** Represents the document to be signed as a string *)

  type signature = string
  (** The cryptographic signature produced for a document *)

  type private_key = Mirage_crypto_ec.Ed25519.priv
  (** Ed25519 private key used for signing documents *)

  type public_key = Mirage_crypto_ec.Ed25519.pub
  (** Ed25519 public key used for signature verification *)

  (** {1 Core Functions} *)

  val generate_keys : unit -> private_key * public_key
  (** Generates a new Ed25519 key pair.
      @return A tuple containing the private and public keys *)

  val hash_document : document -> string
  (** Computes the SHA3-256 hash of a document.
      @param document The input document to hash
      @return The hexadecimal string representation of the hash *)

  val sign_document : private_key -> document -> string * signature
  (** Signs a document using Ed25519.
      @param private_key The private key used for signing
      @param document The document to sign
      @return A tuple containing the document hash and its signature *)

  val verify_signature : public_key -> document -> signature -> bool
  (** Verifies a document's signature.
      @param public_key The public key corresponding to the signing private key
      @param document The original document
      @param signature The signature to verify
      @return true if the signature is valid, false otherwise *)
end
