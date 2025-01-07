(* Import the Searchs module from the Ocaml_searchs library *)
open Ocaml_searchs.Searchs

(* Helper function to generate a sorted random list of integers
   @param n The size of the list to generate
   @return A sorted list of random integers between 0 and 999 *)
let random_list n =
  let rec aux acc n =
    if n = 0 then acc else aux (Random.int 1000 :: acc) (n - 1)
  in
  List.sort compare (aux [] n)

(* Define test parameters *)
let target = 500 (* The value to search for in all benchmarks *)
let small_list = random_list 1000   (* List of 1000 elements *)
let medium_list = random_list 5000  (* List of 5000 elements *)
let large_list = random_list 10000  (* List of 10000 elements *)

(* Benchmark function for small lists (1000 elements)
   Tests linear, binary, jump, and exponential search algorithms *)
let benchmark_small () =
  print_endline "Running benchmarks for small list...";
  let suite =
    [
      ("Linear search (small)", Searchs.linear_search small_list, target);
      ("Binary search (small)", Searchs.binary_search small_list, target);
      ("Jump search (small)", Searchs.jump_search small_list, target);
      ( "Exponential search (small)",
        Searchs.exponential_search small_list,
        target );
    ]
  in
  (* Run each benchmark for at least 3 CPU seconds *)
  let results = Benchmark.throughputN 3 suite in
  Benchmark.tabulate results

(* Benchmark function for medium lists (5000 elements)
   Tests all search algorithms including Fibonacci search *)
let benchmark_medium () =
  print_endline "Running benchmarks for medium list...";
  let suite =
    [
      ("Fibonacci search (medium)", Searchs.fibonacci_search medium_list, target);
      ("Linear search (medium)", Searchs.linear_search medium_list, target);
      ("Binary search (medium)", Searchs.binary_search medium_list, target);
      ("Jump search (medium)", Searchs.jump_search medium_list, target);
      ( "Exponential search (medium)",
        Searchs.exponential_search medium_list,
        target );
      ("Fibonacci search (medium)", Searchs.fibonacci_search medium_list, target);
    ]
  in
  (* Run each benchmark for at least 3 CPU seconds *)
  let results = Benchmark.throughputN 3 suite in
  Benchmark.tabulate results

(* Benchmark function for large lists (10000 elements)
   Tests all search algorithms to compare performance at scale *)
let benchmark_large () =
  print_endline "Running benchmarks for large list...";
  let suite =
    [
      ("Linear search (large)", Searchs.linear_search large_list, target);
      ("Binary search (large)", Searchs.binary_search large_list, target);
      ("Jump search (large)", Searchs.jump_search large_list, target);
      ( "Exponential search (large)",
        Searchs.exponential_search large_list,
        target );
      ("Fibonacci search (large)", Searchs.fibonacci_search large_list, target);
    ]
  in
  (* Run each benchmark for at least 3 CPU seconds *)
  let results = Benchmark.throughputN 3 suite in
  Benchmark.tabulate results

(* Main entry point: run all benchmarks in sequence from small to large *)
let () =
  benchmark_small ();
  benchmark_medium ();
  benchmark_large ()
