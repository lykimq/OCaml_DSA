open Ocaml_trees.Avl_tree

module File_System_Avl_Tree_Balance : sig
  (** {1 Types} *)

  (** Represents a file in the filesystem with a name and content *)
  type file = {
    name : string;      (** Name of the file *)
    content : string    (** Content stored in the file *)
  }

  (** Represents a directory in the filesystem with a name and children nodes *)
  type directory = {
    name : string;                          (** Name of the directory *)
    children : node AVL_Tree.avl_tree      (** AVL tree containing child nodes *)
  }

  (** Variant type representing either a file or directory node *)
  and node =
    | File of file           (** File node containing file data *)
    | Directory of directory (** Directory node containing directory data *)

  (** {1 Functions} *)

  (** Converts a node to its string representation
      @param node The node to convert
      @return String representation of the node *)
  val string_of_node : node -> string

  (** Compares two nodes for ordering in the AVL tree
      @param node1 First node to compare
      @param node2 Second node to compare
      @return Negative if node1 < node2, 0 if equal, positive if node1 > node2 *)
  val compare_nodes : node -> node -> int

  (** Inserts a node into another node (if target is a directory)
      @param target The target node (should be a directory)
      @param new_node The node to insert
      @return Updated node with the insertion *)
  val insert_node : node -> node -> node

  (** Prints the AVL tree representation of nodes
      @param tree The AVL tree to print
      @param indent The indentation string for formatting *)
  val print_node_avl_tree : node AVL_Tree.avl_tree -> string -> unit

  (** Adds a file to a directory node
      @param target The target node (should be a directory)
      @param file The file to add
      @return Updated node with the new file *)
  val add_file : node -> file -> node

  (** Prints the filesystem structure starting from a node
      @param node The root node to start printing from
      @param indent The indentation string for formatting *)
  val print_filesystem : node -> string -> unit

  (** Finds a directory given a path of directory names
      @param path List of directory names representing the path
      @param root The root node to start searching from
      @return Some node if directory is found, None otherwise *)
  val find_directory : string list -> node -> node option

  (** Removes a node from a directory node
      @param target The target node (should be a directory)
      @param to_remove The node to remove
      @return Updated node with the specified node removed *)
  val remove_node : node -> node -> node
end
