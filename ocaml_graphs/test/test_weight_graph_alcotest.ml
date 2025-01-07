open Ocaml_graphs
open Weight_graph
open Alcotest

(** Test adding and taking elements from a priority queue
    - Adds elements with priorities (5, 10), (2, 20), and (8, 30) to the queue.
    - Verifies that elements are taken in order of priority:
      1. First element taken should have priority 2 and value 20.
      2. Second element taken should have priority 5 and value 10.
      3. Third element taken should have priority 8 and value 30.
*)
let test_add_and_take () =
  let open PriorityQueue in
  let pq = create () in
  add pq (5, 10);
  add pq (2, 20);
  add pq (8, 30);

  let p1, v1 = take pq in
  check int "First priority should be 2" 2 p1;
  check int "First value should be B" 20 v1;

  let p2, v2 = take pq in
  check int "Second priority should be 5" 5 p2;
  check int "Second priority shoud be 30" 10 v2;

  let p3, v3 = take pq in
  check int "Third priority should be 8" 8 p3;
  check int "Third priority shoudl be 30" 30 v3

(** Test checking if a priority queue is empty
    - Verifies that a newly created queue is empty.
    - Adds an element and checks that the queue is no longer empty.
    - Removes the element and checks that the queue is empty again.
*)
let test_is_empty () =
  let open PriorityQueue in
  let pq = create () in
  check bool "Init empty" true (is_empty pq);

  add pq (1, 100);
  check bool "It is not empty" false (is_empty pq);

  let _ = take pq in
  check bool "Empty after removing the only element" true (is_empty pq)

(** Setup a weighted graph for testing
    - Creates a graph with 5 vertices and adds undirected edges with weights.
    - The graph structure is as follows:
           0
       10 / \ 5
         1--4
       1 |  |
         2  |
         |  |
       4 \  / 3
          3
    - This setup is used for testing Dijkstra's algorithm.
*)
let setup_graph () =
  let open Weight_graph in
  let g = create 5 in
  (*
       0
   10 / \ 5
     1--4
   1 |  |
     2  |
     |  |
   4 \  / 3
      3
*)
  add_edge g { src = 0; dest = 1; weight = 10 } ~directed:false;
  add_edge g { src = 0; dest = 4; weight = 5 } ~directed:false;
  add_edge g { src = 1; dest = 2; weight = 1 } ~directed:false;
  add_edge g { src = 2; dest = 3; weight = 4 } ~directed:false;
  add_edge g { src = 3; dest = 4; weight = 3 } ~directed:false;
  add_edge g { src = 4; dest = 1; weight = 2 } ~directed:false;
  g

(** Test Dijkstra's algorithm on an undirected graph
    - Uses the graph setup by `setup_graph`.
    - Verifies the shortest path distances from vertex 0 to all other vertices:
      - Distance to vertex 0 should be 0.
      - Distance to vertex 1 should be 7.
      - Distance to vertex 2 should be 8.
      - Distance to vertex 3 should be 8.
      - Distance to vertex 4 should be 5.
*)
let test_dijkstra () =
  let open Weight_graph in
  let g = setup_graph () in
  let dist = dijkstra g 0 in
  check int "Distance to vertex 0 should be 0" 0 dist.(0);
  check int "Distance to vertex 1 should be 7" 7 dist.(1);
  check int "Distance to vertex 2 should be 8" 8 dist.(2);
  check int "Distance to vertex 3 should be 8" 8 dist.(3);
  check int "Distance to vertex 4 should be 5" 5 dist.(4)

(** Test Dijkstra's algorithm on a directed graph
    - Creates a directed graph with 5 vertices and adds directed edges with weights.
    - Verifies the shortest path distances from vertex 0 to all other vertices:
      - Distance to vertex 0 should be 0.
      - Distance to vertex 1 should be 8.
      - Distance to vertex 2 should be 5.
      - Distance to vertex 3 should be 9.
      - Distance to vertex 4 should be 13.
*)
let test_dijkstra_directed () =
  let open Weight_graph in
  let g = create 5 in
  add_edge g { src = 0; dest = 1; weight = 10 } ~directed:true;
  add_edge g { src = 0; dest = 2; weight = 5 } ~directed:true;
  add_edge g { src = 1; dest = 3; weight = 1 } ~directed:true;
  add_edge g { src = 2; dest = 1; weight = 3 } ~directed:true;
  add_edge g { src = 2; dest = 3; weight = 9 } ~directed:true;
  add_edge g { src = 3; dest = 4; weight = 4 } ~directed:true;
  let dist = dijkstra g 0 in
  check int "Distance to vertex 0 should be 0" 0 dist.(0);
  check int "Distance to vertex 1 should be 8" 8 dist.(1);
  check int "Distance to vertex 2 should be 5" 5 dist.(2);
  check int "Distance to vertex 3 should be 9" 9 dist.(3);
  check int "Distance to vertex 4 should be 13" 13 dist.(4)

let edge_testable =
  let open Weight_graph in
  let pp fmt edge =
    Format.fprintf fmt "{src = %d; dest = %d ; weight = %d }" edge.src edge.dest
      edge.weight
  in
  testable pp ( = )

(** Test Kruskal's algorithm for finding the Minimum Spanning Tree (MST)
    - Creates a graph with 4 vertices and adds undirected edges with weights.
    - Normalizes edges to ensure consistent comparison.
    - Verifies that the MST contains the expected edges:
      - Edge from 2 to 3 with weight 4.
      - Edge from 0 to 3 with weight 5.
      - Edge from 0 to 1 with weight 10.
*)
let test_kruskal () =
  let open Weight_graph in
  let g = create 4 in
  add_edge g { src = 0; dest = 1; weight = 10 } ~directed:false;
  add_edge g { src = 0; dest = 2; weight = 6 } ~directed:false;
  add_edge g { src = 0; dest = 3; weight = 5 } ~directed:false;
  add_edge g { src = 1; dest = 3; weight = 15 } ~directed:false;
  add_edge g { src = 2; dest = 3; weight = 4 } ~directed:false;

  (* Normalize the edges by sorting src and dest within each edge.
     It ensures that the src is always smaller vertex and dest is always
     larger vertex.
  *)
  let normalize_edge edge =
    { edge with src = min edge.src edge.dest; dest = max edge.src edge.dest }
  in
  let normalize_edges edges =
    List.map normalize_edge edges |> List.sort compare
  in

  let mst = normalize_edges (kruskal g) in

  (* Expected MST edges *)
  let expected_mst =
    normalize_edges
      [
        { src = 2; dest = 3; weight = 4 };
        { src = 0; dest = 3; weight = 5 };
        { src = 0; dest = 1; weight = 10 };
      ]
  in
  (* Sort both the computed MST and expected MST *)
  let sort_edges edges =
    List.sort
      (fun a b ->
        match compare a.src b.src with
        | 0 -> (
            match compare a.dest b.dest with
            | 0 -> compare a.weight b.weight
            | c -> c)
        | c -> c)
      edges
  in
  check (list edge_testable) "MST provided by Kruskal's algorithm"
    (sort_edges mst) (sort_edges expected_mst)

let () =
  let open Alcotest in
  run "Priority Queue tests"
    [
      ( "PriorityQueue",
        [ test_case "Add and take elements" `Quick test_add_and_take ] );
      ("PriorityEmpty", [ test_case "Check empty" `Quick test_is_empty ]);
      ("Dijkstra", [ test_case "Check Dijkstra" `Quick test_dijkstra ]);
      ( "Dijkstra Directed Graph",
        [
          test_case "Check Dijkstra Directed graph" `Quick
            test_dijkstra_directed;
        ] );
      ("Kruskal", [ test_case "Kruskal" `Quick test_kruskal ]);
    ]
