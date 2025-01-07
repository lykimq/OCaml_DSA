module Undirect_graph : sig
  (** The type representing an undirected graph *)
  type t

  (** The type representing an edge as a pair of vertex indices (u, v) *)
  type edge = int * int

  (** [create n] creates a new undirected graph with [n] vertices (labeled 0 to n-1) and no edges
      @param n The number of vertices in the graph
      @return A new empty graph with n vertices *)
  val create : int -> t

  (** [add_edge g (u,v)] adds an undirected edge between vertices [u] and [v] in graph [g]
      @param g The graph to modify
      @param (u,v) The edge to add, represented as a pair of vertex indices
      @raise Invalid_argument if either vertex index is out of bounds *)
  val add_edge : t -> edge -> unit

  (** [neighbors g v] returns the list of vertices adjacent to vertex [v] in graph [g]
      @param g The graph to query
      @param v The vertex whose neighbors to find
      @return A list of vertex indices representing the neighbors of v
      @raise Invalid_argument if the vertex index is out of bounds *)
  val neighbors : t -> int -> int list

  (** [vertices g] returns a list of all vertices in the graph [g]
      @param g The graph to query
      @return A list of all vertex indices in the graph *)
  val vertices : t -> int list

  (** [dfs g start fmt] performs a depth-first search starting from vertex [start]
      and prints the traversal to formatter [fmt]
      @param g The graph to traverse
      @param start The starting vertex for the traversal
      @param fmt The formatter to output the traversal
      @raise Invalid_argument if the start vertex is out of bounds *)
  val dfs : t -> int -> Format.formatter -> unit

  (** [bfs g start fmt] performs a breadth-first search starting from vertex [start]
      and prints the traversal to formatter [fmt]
      @param g The graph to traverse
      @param start The starting vertex for the traversal
      @param fmt The formatter to output the traversal
      @raise Invalid_argument if the start vertex is out of bounds *)
  val bfs : t -> int -> Format.formatter -> unit
end
