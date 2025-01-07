module PasswordStorage : sig
  (** [hash_password password] takes a plain text password and returns a secure hash.
      The hash is generated using SHA-256 and includes a random salt for security.
      @param password The plain text password to hash
      @return A string containing the salted hash in a standard format *)
  val hash_password : string -> string

  (** [verify_password password hash] compares a plain text password against a stored hash.
      The function extracts the salt from the stored hash and verifies the password matches.
      @param password The plain text password to verify
      @param hash The stored password hash to check against
      @return true if the password matches the hash, false otherwise *)
  val verify_password : string -> string -> bool
end
