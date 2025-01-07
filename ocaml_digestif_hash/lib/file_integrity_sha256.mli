open Digestif

module FileIntegrityChecker : sig
  (** [sha256_hash_file path] computes the SHA256 hash of the file at [path].
      @param path The path to the file to hash
      @return SHA256 hash digest of the file contents
      @raise Sys_error if the file cannot be read *)
  val sha256_hash_file : string -> SHA256.t

  (** [hash_to_hex hash] converts a SHA256 hash digest to its hexadecimal string representation.
      @param hash The SHA256 hash digest to convert
      @return Hexadecimal string representation of the hash *)
  val hash_to_hex : SHA256.t -> string

  (** [save_hash hash filepath] saves the hexadecimal representation of [hash] to a file at [filepath].
      @param hash The SHA256 hash digest to save
      @param filepath The path where the hash should be saved
      @raise Sys_error if the file cannot be written *)
  val save_hash : SHA256.t -> string -> unit

  (** [read_stored_hash filepath] reads a previously stored hash from [filepath].
      @param filepath The path to the file containing the stored hash
      @return The stored hash as a hexadecimal string
      @raise Sys_error if the file cannot be read *)
  val read_stored_hash : string -> string

  (** [verify_file_integrity filepath hash_filepath] verifies if a file's current hash matches its stored hash.
      @param filepath The path to the file to verify
      @param hash_filepath The path to the file containing the stored hash
      @return true if the current hash matches the stored hash, false otherwise
      @raise Sys_error if either file cannot be read *)
  val verify_file_integrity : string -> string -> bool
end
