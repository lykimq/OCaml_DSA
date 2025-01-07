(** Red_Black_Tree module provides an implementation of a self-balancing binary search tree *)
module Red_Black_Tree : sig
  (** Color of a node in the Red-Black tree - either Red or Black *)
  type color = Red | Black

  (** Tree data structure with polymorphic type 'a
      - Empty represents a leaf (null node)
      - Node contains:
        - color: Red or Black
        - value: data stored in the node
        - left: left subtree
        - right: right subtree
  *)
  type 'a tree =
    | Empty
    | Node of { color : color; value : 'a; left : 'a tree; right : 'a tree }

  (** Returns an empty tree *)
  val empty : 'a tree

  (** Pretty-prints the tree structure to the provided formatter
      Only works with integer trees (int tree) *)
  val print_tree : Format.formatter -> int tree -> unit

  (** Inserts a new value into the tree while maintaining Red-Black properties
      Returns the new balanced tree *)
  val insert : 'a -> 'a tree -> 'a tree

  (** Searches for a value in the tree
      Returns true if found, false otherwise *)
  val search : 'a tree -> 'a -> bool

  (** Deletes a value from the tree while maintaining Red-Black properties
      - cmp: comparison function that returns:
        - negative if first arg < second arg
        - zero if equal
        - positive if first arg > second arg
      Returns the new balanced tree *)
  val delete : cmp:('a -> 'b -> int) -> 'a -> 'b tree -> 'b tree
end
