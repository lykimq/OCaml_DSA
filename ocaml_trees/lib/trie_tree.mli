module Trie_Tree : sig
  (** Represents a node in the Trie tree structure.
      - children: maps characters to child nodes
      - is_end_of_word: indicates if this node represents the end of a word *)
  type t = { children : (char, t) Hashtbl.t; mutable is_end_of_word : bool }

  (** Creates a new empty Trie node *)
  val create_node : unit -> t

  (** Inserts a string into the Trie *)
  val insert : t -> string -> unit

  (** Searches for an exact string match in the Trie.
      Returns true if the string exists, false otherwise *)
  val search : t -> string -> bool

  (** Returns a list of all words stored in the Trie *)
  val all_words : t -> string list

  (** Returns a list of all words in the Trie that start with the given prefix *)
  val words_with_prefix : t -> string -> string list

  (** Counts the number of words in the Trie that start with the given prefix *)
  val count_words_with_prefix : t -> string -> int

  (** Removes a word from the Trie if it exists *)
  val delete : t -> string -> unit
end
