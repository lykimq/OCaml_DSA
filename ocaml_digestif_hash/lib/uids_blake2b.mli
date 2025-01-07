module UniqueIdentifier : sig
  (* Generate a unique identifier from a string input using BLAKE2b
     @param input The source string to generate the UID from
     @return A hex-encoded BLAKE2b hash string *)
  val generate_uid : string -> string

  (* Verify if a given UID matches the expected hash of an input string
     @param input The original source string
     @param uid The UID to verify against
     @return true if the UID matches the hash of the input, false otherwise *)
  val verify_uid : string -> string -> bool

  (* Create a shortened version of a UID while maintaining uniqueness
     @param uid The original UID to shorten
     @param length The desired length of the shortened UID
     @return A truncated version of the UID with specified length *)
  val shorten_uid : string -> int -> string

  (* Check if a string matches the expected format of a valid UID
     @param uid The string to validate
     @return true if the string is a valid UID format, false otherwise *)
  val is_valid_uid : string -> bool

  (* Combine multiple UIDs into a single UID
     @param uids List of UIDs to combine
     @return A new UID generated from the combination of input UIDs *)
  val combine_uids : string list -> string

  (* Generate a UID from multiple input fields
     @param fields List of strings to generate a combined UID from
     @return A single UID generated from all input fields *)
  val generate_uid_from_multiple_fields : string list -> string
end
