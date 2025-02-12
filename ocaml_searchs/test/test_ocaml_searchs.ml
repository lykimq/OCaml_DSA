open Alcotest
open Ocaml_searchs.Searchs

let sample_list = [ 1; 3; 5; 7; 9; 11 ]

(** Test linear search algorithm
    Tests two cases:
    1. Successfully finding an element (7) in the list
    2. Failing to find a non-existent element (12) *)
let test_linear_search () =
  check bool "Found target" true (Searchs.linear_search sample_list 7);
  check bool "Target not found" false (Searchs.linear_search sample_list 12)

(** Test binary search algorithm
    Tests two cases:
    1. Successfully finding an element (5) in the sorted list
    2. Failing to find a non-existent element (18) *)
let test_binary_search () =
  check bool "Found target" true (Searchs.binary_search sample_list 5);
  check bool "Target not found" false (Searchs.binary_search sample_list 18)

(** Test jump search algorithm
    Uses a longer sorted list and tests:
    1. Successfully finding an element (13) in the list
    2. Failing to find a non-existent element (18) *)
let test_jump_search () =
  let lst = [ 1; 3; 5; 7; 9; 11; 13; 15; 17 ] in
  check bool "Found target" true (Searchs.jump_search lst 13);
  check bool "Target not found" false (Searchs.jump_search lst 18)

(** Test interpolation search algorithm
    Uses an evenly distributed list of numbers and tests:
    1. Successfully finding an element (70) using custom compare and to_int functions
    2. Failing to find a non-existent element (25) *)
let test_interpolation_search () =
  let lst = [ 10; 20; 30; 40; 50; 60; 70; 80; 90; 100 ] in
  let to_int a = a in
  check bool "Found target" true
    (Searchs.interpolation_search ~compare:Int.compare ~to_int lst 70);
  check bool "Target not found" false
    (Searchs.interpolation_search ~compare:Int.compare ~to_int lst 25)

(** Test fibonacci search algorithm
    Uses a list containing Fibonacci numbers and tests:
    1. Successfully finding an element (21) in the list
    2. Failing to find a non-existent element (90) *)
let test_fibonacci_search () =
  let lst = [ 1; 2; 3; 5; 8; 13; 21; 34; 55; 89 ] in
  check bool "Found target" true (Searchs.fibonacci_search lst 21);
  check bool "Target not found" false (Searchs.fibonacci_search lst 90)

let test_set =
  [
    ("Linear Search", `Quick, test_linear_search);
    ("Binary Search", `Quick, test_binary_search);
    ("Jump Search", `Quick, test_jump_search);
    ("Interpolation Search", `Quick, test_interpolation_search);
    ("Fibonacci Search", `Quick, test_fibonacci_search);
  ]

let () = run "Search Algorithm Tests" [ ("search_tests", test_set) ]
