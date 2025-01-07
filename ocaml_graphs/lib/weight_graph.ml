module PriorityQueue : sig
  type t

  val create : unit -> t
  val add : t -> int * int -> unit
  val take : t -> int * int
  val is_empty : t -> bool
end = struct
  type t = (int * int) list ref

  let create () = ref []

  (* Lower numberial values represent higher priorities *)
  let add pq (priority, value) =
    let rec insert = function
      | [] -> [ (priority, value) ]
      | (p, v) :: rest as l ->
          (* If the priority of the new element is less (higher priority)
             insert it before the current element *)
          if priority < p then (priority, value) :: l else (p, v) :: insert rest
    in
    (* Update the priority queue with the new list *)
    pq := insert !pq

  (* The element with the highest priority (the smallest priority number) is
     always at the front of the list *)
  let take pq =
    match !pq with
    | [] -> failwith "PriorityQueue is empty"
    | (p, v) :: rest ->
        (* Update ref pq to point to the new list *)
        pq := rest;
        (* Take the first element (highest priority) and
           update the queue to remove it *)
        (p, v)

  let is_empty pq = !pq = []
end

module Weight_graph : sig
  type edge = { src : int; dest : int; weight : int }
  type t = { num_vertices : int; edges : edge list array }

  val create : int -> t
  val add_edge : t -> edge -> directed:bool -> unit
  val neighbors : t -> int -> (int * int) list
  val vertices : t -> int list
  val dijkstra : t -> int -> int array
  val kruskal : t -> edge list
end = struct
  (* An edge is defined by a source vertex, a destination vertex and a weight *)
  type edge = { src : int; dest : int; weight : int }
  type t = { num_vertices : int; edges : edge list array }

  (* Create a graph with a given number of vertices and no edges *)
  let create num_vertices = { num_vertices; edges = Array.make num_vertices [] }

  (* Add an edge to the graph *)
  let add_edge g { src; dest; weight } ~directed =
    if src < g.num_vertices && dest < g.num_vertices then (
      g.edges.(src) <- { src; dest; weight } :: g.edges.(src);
      if not directed then
        g.edges.(dest) <- { src = dest; dest = src; weight } :: g.edges.(dest))
    else failwith "Vertex out of bounds"

  (* Get all neighbor of a given vertex, returns a list of
     (neighbor, weight) pair *)
  let neighbors g v =
    if v < g.num_vertices then
      List.map (fun edge -> (edge.dest, edge.weight)) g.edges.(v)
    else failwith "Vertex out of bounds"

  (* Get a list of all vertices in the graph *)
  let vertices g = List.init g.num_vertices (fun x -> x)

  (* Dijkstra's Algorithm Functions *)

  (* init_dijkstra: Initializes the data structures needed for Dijkstra's algorithm
     @param g: The graph to traverse
     @param start: The starting vertex
     @return: A tuple containing:
       - dist: Array of distances from start to each vertex (initialized to max_int)
       - prio_queue: Priority queue initialized with the start vertex
  *)
  let init_dijkstra g start =
    let dist = Array.make g.num_vertices max_int in
    dist.(start) <- 0;
    let prio_queue = PriorityQueue.create () in
    PriorityQueue.add prio_queue (0, start);
    (dist, prio_queue)

  (* process_vertex: Updates the distances to all neighbors of a given vertex
     @param g: The graph being traversed
     @param dist: Array of current shortest distances
     @param prio_queue: Priority queue for vertex processing
     @param u: Current vertex being processed

     For each neighbor v of vertex u:
     1. Calculates potential new distance through u
     2. If new distance is shorter, updates dist[v] and adds to queue
  *)
  let process_vertex g dist prio_queue u =
    List.iter
      (fun (v, weight) ->
        let new_dist = dist.(u) + weight in
        if new_dist < dist.(v) then (
          dist.(v) <- new_dist;
          PriorityQueue.add prio_queue (new_dist, v)))
      (neighbors g u)

  (* dijkstra: Finds shortest paths from a start vertex to all other vertices
     @param g: The graph to analyze
     @param start: The starting vertex
     @return: Array where dist[v] is the shortest distance from start to vertex v

     Algorithm:
     1. Initialize distances and priority queue
     2. While queue not empty:
        - Take vertex with minimum distance
        - Process all its neighbors
        - Update distances if shorter path found
  *)
  let dijkstra g start =
    let dist, prio_queue = init_dijkstra g start in

    let rec process_queue prio_queue =
      if not (PriorityQueue.is_empty prio_queue) then
        let current_dist, u = PriorityQueue.take prio_queue in
        if current_dist <= dist.(u) then (
          process_vertex g dist prio_queue u;
          process_queue prio_queue)
    in
    process_queue prio_queue;
    dist

  (* Kruskal's Algorithm:
     Use this algorithm to find the minimum spanning tree (MST) of a
     connected, undirected graph. The MST is a subset of the edges that connects
     all the vertices together, without any cycles, and with the minimum
     possible total edge weight.
        1. Retrieve all edges: gather all edges from the graph.
        2. Sort the edges: by weight
        3. Union-Find structure: to check for cycles.
        4. Build the MST: iterate through the sorted edges, adding
        them to the MST if they don't form a cycle.
  *)

  (* Retrieve all edges from the graph *)
  let get_edges g =
    Array.fold_left
      (fun acc edge_list -> List.rev_append edge_list acc)
      [] g.edges

  (* Union-Find Functions for Kruskal's Algorithm *)

  (* make_set: Creates disjoint sets for each vertex
     @param n: Number of vertices
     @return: Tuple of (parent array, rank array) where:
       - parent[i] initially points to itself
       - rank[i] tracks the depth of each tree
  *)
  let make_set n =
    let parent = Array.init n (fun i -> i) in
    let rank = Array.make n 0 in
    (parent, rank)

  (* find: Finds the root of the set containing vertex i
     @param parent: Array tracking parent relationships
     @param i: Vertex to find the root for
     @return: Root vertex of the set

     Uses path compression: all nodes in find path point directly to root
  *)
  let find parent i =
    let rec aux i acc =
      if parent.(i) = i then (
        List.iter (fun x -> parent.(x) <- i) acc;
        i)
      else aux parent.(i) (i :: acc)
    in
    aux i []

  (* Union two sets by rank *)
  let union parent rank x y =
    let root_x = find parent x in
    let root_y = find parent y in
    (* Only unite the trees if they have different root *)
    if root_x <> root_y then
      if rank.(root_x) < rank.(root_y) then
        (* Attach the tree with the smaller rank under the
           tree with the larger rank *)
        parent.(root_x) <- root_y
      else if rank.(root_x) > rank.(root_y) then
        (* Attach the tree with the larger rank under the tree
           with the smaller rank *)
        parent.(root_y) <- root_x
      else (
        (* If ranks are the same, choose one as the new root
           and increment its rank *)
        parent.(root_y) <- root_x;
        rank.(root_x) <- rank.(root_x) + 1)

  (* Kruskal's alrogithm *)
  let kruskal g =
    let mst = ref [] in
    (* Get all edges and sort them by weight in ascending order *)
    let edges = get_edges g in
    let sorted_edges = List.sort (fun a b -> compare a.weight b.weight) edges in
    (* init the union-find structure*)
    let parent, rank = make_set g.num_vertices in

    (* Process each edge in the sorted list *)
    List.iter
      (fun edge ->
        (* Find the roots of the source and destination vertices *)
        let u_root = find parent edge.src in
        let v_root = find parent edge.dest in
        (* If the roots are differnt, adding this edge won't form a cycle *)
        if u_root <> v_root then (
          (* Add the edge in MST *)
          mst := edge :: !mst;
          (* union the two sets to connect the components *)
          union parent rank u_root v_root))
      sorted_edges;
    (* Return the list of edges in the MST *)
    !mst
end
