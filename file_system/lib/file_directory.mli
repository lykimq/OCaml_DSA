module File_Directory : sig
  (** Represents a file system with files and directories *)

  type file = { name : string; content : string }
  (** Represents a file with a name and content *)

  type directory = { name : string; children : node list }
  (** Represents a directory with a name and a list of child nodes *)

  and node = File of file | Directory of directory
  (** A node in the file system, which can be either a file or a directory *)

  val add_file : node -> file -> node
  (** [add_file node file] adds a file to the given node.
      If the node is a directory, the file is added to its children.
      If the node is a file, returns the node unchanged.
      @param node The target node where the file should be added
      @param file The file to be added
      @return The updated node with the new file *)

  val print_filesystem : node -> string -> unit
  (** [print_filesystem node indent] prints the file system structure starting from the given node.
      @param node The root node to start printing from
      @param indent The initial indentation string
      @return unit *)

  val find_directory : string list -> node -> node option
  (** [find_directory path node] finds a directory at the specified path.
      @param path List of directory names forming the path to search
      @param node The root node to start the search from
      @return Some node if the directory is found, None otherwise *)

  val remove_node : string -> node -> node
  (** [remove_node name node] removes a node with the given name from the file system.
      @param name The name of the node to remove
      @param node The root node to start the removal from
      @return The updated node with the specified node removed *)
end
