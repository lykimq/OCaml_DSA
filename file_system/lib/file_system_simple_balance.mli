(** Simpler Threshold-Based Balancing:
    - Use case: If the file system is relatively small, or modifications are
      infrequent, the simpler approach may be sufficient.
      It is easier to implememt and maintain and introduces less overhead.
    - Trade-Off: You accept potentially worse performance in certain cases
      (if the tree becomes unblanced) in exchange for simplicity and lower resource
      usage.
*)
module File_System_Simple_Balance : sig
  (** Represents a file in the file system *)
  type file = {
    name : string;      (** Name of the file *)
    content : string;   (** Content stored in the file *)
  }

  (** Represents a directory and its contents in the file system *)
  type directory = {
    name : string;      (** Name of the directory *)
    children : node list; (** List of child nodes (files or directories) *)
  }

  (** Represents a node in the file system, which can be either a file or directory *)
  and node =
    | File of file           (** A file node *)
    | Directory of directory (** A directory node *)

  (** Calculate the depth of a node in the file system tree
      @param node The node to calculate depth for
      @return The depth of the node (1 for leaf nodes, max child depth + 1 for directories)
  *)
  val calculate_depth : node -> int

  (** Add a file to the file system while maintaining balance
      @param node The root node to add the file to
      @param file The file to be added
      @return A new root node containing the added file
  *)
  val add_file_balanced : node -> file -> node

  (** Print the file system structure starting from a given node
      @param node The root node to start printing from
      @param indent The initial indentation string (usually empty or spaces)
      @return unit
  *)
  val print_filesystem : node -> string -> unit

  (** Find a directory in the file system using a path
      @param path List of directory names representing the path
      @param node The root node to start searching from
      @return Some node if directory is found, None otherwise
  *)
  val find_directory : string list -> node -> node option

  (** Remove a node (file or directory) from the file system
      @param name Name of the node to remove
      @param node The root node to remove from
      @return A new root node with the specified node removed
  *)
  val remove_node : string -> node -> node
end
