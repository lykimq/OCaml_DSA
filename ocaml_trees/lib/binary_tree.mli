(** {1 Binary Tree Implementation}

    This module provides a simple binary tree data structure implementation with
    basic operations for insertion, searching, and various tree traversal methods.
*)

module Binary_Tree : sig
  (** {2 Types} *)

  type 'a tree
  (** The type representing a binary tree.
      The tree is parameterized over type ['a] allowing it to store any type of value. *)

  (** {2 Construction} *)

  val empty : 'a tree
  (** Creates an empty binary tree. *)

  val insert : 'a -> 'a tree -> 'a tree
  (** [insert x tree] inserts the value [x] into the binary tree [tree].

      @param x The value to insert
      @param tree The existing binary tree
      @return A new binary tree containing the inserted value
      @note If [x] already exists in the tree, the tree remains unchanged *)

  (** {2 Query Operations} *)

  val search : 'a -> 'a tree -> bool
  (** [search x tree] checks if a value exists in the binary tree.

      @param x The value to search for
      @param tree The binary tree to search in
      @return [true] if the value exists, [false] otherwise *)

  (** {2 Traversal Operations} *)

  val inorder : 'a tree -> 'a list
  (** [inorder tree] performs an in-order traversal of the tree.

      Visits the nodes in the following order:
      - Left subtree
      - Root
      - Right subtree

      @param tree The binary tree to traverse
      @return A list of elements in in-order traversal order *)

  val preorder : 'a tree -> 'a list
  (** [preorder tree] performs a pre-order traversal of the tree.

      Visits the nodes in the following order:
      - Root
      - Left subtree
      - Right subtree

      @param tree The binary tree to traverse
      @return A list of elements in pre-order traversal order *)

  val postorder : 'a tree -> 'a list
  (** [postorder tree] performs a post-order traversal of the tree.

      Visits the nodes in the following order:
      - Left subtree
      - Right subtree
      - Root

      @param tree The binary tree to traverse
      @return A list of elements in post-order traversal order *)

  (** {2 Utility Functions} *)

  val print_tree : int tree -> unit
  (** [print_tree tree] prints a visual representation of the tree.

      @param tree The binary tree to print
      @note This function only works with integer trees *)
end
