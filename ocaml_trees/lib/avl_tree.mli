(** AVL Tree implementation module *)
module AVL_Tree : sig
  (** Type representing an AVL tree node
      An AVL tree is a self-balancing binary search tree where the heights
      of the two child subtrees of any node differ by at most one *)
  type 'a avl_tree =
    | Empty  (** Empty tree node *)
    | Node of {
        value : 'a;    (** Value stored in the node *)
        left : 'a avl_tree;   (** Left subtree *)
        right : 'a avl_tree;  (** Right subtree *)
        height : int;   (** Height of the node *)
      }

  (** Returns an empty AVL tree *)
  val empty : 'a avl_tree

  (** Returns the height of the given AVL tree
      @param tree The input AVL tree
      @return The height of the tree *)
  val height : 'a avl_tree -> int

  (** Converts the tree to a string representation for printing
      @param tree The input integer AVL tree
      @return String representation of the tree *)
  val print_tree : int avl_tree -> string

  (** Creates a new AVL tree node with the given value and subtrees
      @param value The value to store in the node
      @param left The left subtree
      @param right The right subtree
      @return A new AVL tree node *)
  val make_node : 'a -> 'a avl_tree -> 'a avl_tree -> 'a avl_tree

  (** Performs a right rotation on the given AVL tree
      @param tree The input AVL tree
      @return The rotated AVL tree *)
  val rotate_right : 'a avl_tree -> 'a avl_tree

  (** Performs a left rotation on the given AVL tree
      @param tree The input AVL tree
      @return The rotated AVL tree *)
  val rotate_left : 'a avl_tree -> 'a avl_tree

  (** Performs a left-right double rotation on the given AVL tree
      @param tree The input AVL tree
      @return The rotated AVL tree *)
  val rotate_left_right : 'a avl_tree -> 'a avl_tree

  (** Performs a right-left double rotation on the given AVL tree
      @param tree The input AVL tree
      @return The rotated AVL tree *)
  val rotate_right_left : 'a avl_tree -> 'a avl_tree

  (** Inserts a value into the AVL tree while maintaining balance
      @param cmp The comparison function for ordering elements
      @param value The value to insert
      @param tree The input AVL tree
      @return The new AVL tree with the inserted value *)
  val insert : cmp:('a -> 'a -> int) -> 'a -> 'a avl_tree -> 'a avl_tree

  (** Deletes a value from the AVL tree while maintaining balance
      @param cmp The comparison function for ordering elements
      @param value The value to delete
      @param tree The input AVL tree
      @return The new AVL tree with the value removed *)
  val delete : cmp:('a -> 'a -> int) -> 'a -> 'a avl_tree -> 'a avl_tree

  (** Searches for a value in the AVL tree
      @param cmp The comparison function for ordering elements
      @param value The value to search for
      @param tree The input AVL tree
      @return true if the value is found, false otherwise *)
  val search : cmp:('a -> 'a -> int) -> 'a -> 'a avl_tree -> bool
end
