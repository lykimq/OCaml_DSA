module Undirect_graph : sig
  (* Type representing an undirected graph with adjacency list representation *)
  type t = { num_vertices : int; edges : int list array }
  (* Edge is represented as a pair of vertices *)
  type edge = int * int

  (* Module interface declarations *)
  val create : int -> t
  val add_edge : t -> edge -> unit
  val neighbors : t -> int -> int list
  val vertices : t -> int list
  val dfs : t -> int -> Format.formatter -> unit
  val bfs : t -> int -> Format.formatter -> unit
end = struct
  type t = { num_vertices : int; edges : int list array }
  type edge = int * int

  (* Creates a new graph with specified number of vertices *)
  (* Each vertex starts with an empty list of neighbors *)
  let create num_vertices = { num_vertices; edges = Array.make num_vertices [] }

  (* Adds an undirected edge between vertices u and v *)
  (* Since it's undirected, we add both (u,v) and (v,u) to the edge list *)
  let add_edge g (u, v) =
    if u < g.num_vertices && v < g.num_vertices then (
      g.edges.(u) <- v :: g.edges.(u);
      g.edges.(v) <- u :: g.edges.(v))
    else failwith "Vertex out of bounds"

  (* Returns the list of neighbors for a given vertex *)
  (* List is reversed to maintain order of addition *)
  let neighbors g v =
    if v < g.num_vertices then List.rev g.edges.(v)
    else failwith "Vertex out of bounds "

  (* Returns a list of all vertices in the graph *)
  let vertices g = List.init g.num_vertices (fun x -> x)

  (* Depth-First Search implementation *)
  (* Prints vertices in DFS order to the provided formatter *)
  let dfs g start fmt =
    (* Track visited vertices to avoid cycles *)
    let visited = Array.make (List.length (vertices g)) false in
    (* Use stack for iterative DFS instead of recursion *)
    let stack = Stack.create () in
    Stack.push start stack;

    (* Used for formatting output with proper spacing *)
    let is_first_vertex = ref true in

    (* Main DFS loop *)
    let rec dfs_iter () =
      if not (Stack.is_empty stack) then
        let v = Stack.pop stack in
        if not visited.(v) then (
          (* Mark current vertex as visited *)
          visited.(v) <- true;
          (* Print vertex with appropriate spacing *)
          if !is_first_vertex then (
            Format.fprintf fmt "%d" v;
            is_first_vertex := false)
          else Format.fprintf fmt " %d" v;
          (* Process all unvisited neighbors *)
          List.iter
            (fun neighbor ->
              if not visited.(neighbor) then Stack.push neighbor stack)
            (neighbors g v);
          dfs_iter ())
    in
    dfs_iter ();
    Format.fprintf fmt "@."

  (* Breadth-First Search implementation *)
  (* Prints vertices in BFS (level) order to the provided formatter *)
  let bfs g start fmt =
    (* Track visited vertices to avoid cycles *)
    let visited = Array.make (List.length (vertices g)) false in
    (* Use queue for level-order traversal *)
    let queue = Queue.create () in
    Queue.add start queue;
    visited.(start) <- true;

    (* Used for formatting output with proper spacing *)
    let is_first_vertex = ref true in

    (* Main BFS loop *)
    let rec bfs_iter () =
      if not (Queue.is_empty queue) then (
        let v = Queue.take queue in
        (* Print vertex with appropriate spacing *)
        if !is_first_vertex then (
          Format.fprintf fmt "%d" v;
          is_first_vertex := false)
        else Format.fprintf fmt " %d" v;
        (* Process all unvisited neighbors *)
        List.iter
          (fun neighbor ->
            if not visited.(neighbor) then (
              Queue.add neighbor queue;
              visited.(neighbor) <- true))
          (neighbors g v);
        bfs_iter ())
    in
    bfs_iter ();
    Format.fprintf fmt "@."
end
