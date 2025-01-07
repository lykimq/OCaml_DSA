module String_Conversion : sig
  (** [escape_string s] escapes special characters in string [s].
      This function converts characters like newlines, tabs, and quotes
      into their escaped representations.
      @param s The input string to be escaped
      @return The escaped string *)
  val escape_string : string -> string

  (** [hex_of_string s] converts string [s] into its hexadecimal representation.
      Each byte in the input string is converted to a two-digit hexadecimal number.
      @param s The input string to be converted
      @return The hexadecimal representation of the input string *)
  val hex_of_string : string -> string

  (** [readable_of_string s] converts string [s] into a human-readable format.
      Non-printable characters are converted to their escaped or hex representations
      to make the string suitable for display.
      @param s The input string to be converted
      @return The human-readable representation of the input string *)
  val readable_of_string : string -> string

  (** [base64_of_string s] encodes string [s] into its base64 representation.
      The resulting string contains only ASCII characters and is suitable
      for transmission in contexts where binary data cannot be used directly.
      @param s The input string to be encoded
      @return The base64 representation of the input string *)
  val base64_of_string : string -> string
end
