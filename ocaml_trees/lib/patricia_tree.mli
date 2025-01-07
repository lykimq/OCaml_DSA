(** Patricia Tree implementation - a space-efficient trie data structure for storing strings *)
module Patricia_Tree : sig
  (** Represents a node in the Patricia Tree
      @field prefix The shared prefix string at this node
      @field children List of (character, node) pairs representing branches
      @field is_terminal Boolean indicating if this node represents a complete word
  *)
  type node = {
    prefix : string;
    children : (char * node) list;
    is_terminal : bool;
  }

  (** The tree type, which is an optional node (None represents an empty tree) *)
  type t = node option

  (** Returns an empty Patricia Tree *)
  val empty : t option

  (** Searches for a string in the tree
      @param string The string to search for
      @param node option The tree to search in
      @return bool True if the string exists in the tree, false otherwise
  *)
  val find : string -> node option -> bool

  (** Inserts a string into the tree
      @param string The string to insert
      @param node option The tree to insert into
      @return node option The modified tree with the new string inserted
  *)
  val insert : string -> node option -> node option

  (** Removes a string from the tree
      @param string The string to delete
      @param node option The tree to delete from
      @return node option The modified tree with the string removed
  *)
  val delete : string -> node option -> node option

  (** Converts the tree to a list of strings
      @param node option The tree to convert
      @return string list List of all strings stored in the tree
  *)
  val to_list : node option -> string list
end
