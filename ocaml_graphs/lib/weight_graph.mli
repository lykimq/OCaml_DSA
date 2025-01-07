module PriorityQueue : sig
  type t

  (** Creates a new empty priority queue *)
  val create : unit -> t

  (** Adds a pair of integers (typically vertex and weight) to the priority queue *)
  val add : t -> int * int -> unit

  (** Removes and returns the pair with the lowest second value (weight) from the queue *)
  val take : t -> int * int

  (** Returns true if the priority queue is empty, false otherwise *)
  val is_empty : t -> bool
end

module Weight_graph : sig
  (** Represents an edge in the weighted graph with source vertex, destination vertex, and weight *)
  type edge = { src : int; dest : int; weight : int }

  (** Represents a weighted graph with number of vertices and an array of edge lists *)
  type t = { num_vertices : int; edges : edge list array }

  (** Creates a new empty graph with the specified number of vertices *)
  val create : int -> t

  (** Adds an edge to the graph. If directed is false, adds edges in both directions *)
  val add_edge : t -> edge -> directed:bool -> unit

  (** Returns a list of (vertex, weight) pairs representing neighbors of the given vertex *)
  val neighbors : t -> int -> (int * int) list

  (** Returns a list of all vertices in the graph (0 to num_vertices - 1) *)
  val vertices : t -> int list

  (** Implements Dijkstra's algorithm to find shortest paths from source vertex.
      Returns an array where array[i] is the shortest distance to vertex i *)
  val dijkstra : t -> int -> int array

  (** Implements Kruskal's algorithm to find the minimum spanning tree.
      Returns a list of edges that form the MST *)
  val kruskal : t -> edge list
end
