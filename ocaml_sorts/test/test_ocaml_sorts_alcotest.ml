open Alcotest
open Ocaml_sorts.Sorts

(* Helper function to create test cases with a label, input, and expected output *)
let test_input ~label ~input ~expected = [ (label, input, expected) ]

(* Test bubble sort implementation with various cases *)
let test_bubble_sort () =
  let test_1 =
    test_input ~label:"Sorted list" ~input:[ 1; 2; 3; 4; 5 ]
      ~expected:[ 1; 2; 3; 4; 5 ]
  in
  let test_2 =
    test_input ~label:"Reverse sorted list" ~input:[ 5; 4; 3; 2; 1 ]
      ~expected:[ 1; 2; 3; 4; 5 ]
  in
  let test_3 =
    test_input ~label:"List with duplicates" ~input:[ 3; 1; 2; 3; 2 ]
      ~expected:[ 1; 2; 2; 3; 3 ]
  in
  let test_4 =
    test_input ~label:"List with all same elements" ~input:[ 2; 2; 2; 2 ]
      ~expected:[ 2; 2; 2; 2 ]
  in
  let test_5 = test_input ~label:"Empty list" ~input:[] ~expected:[] in
  let test_cases = test_1 @ test_2 @ test_3 @ test_4 @ test_5 in
  List.iter
    (fun (desc, input, expected) ->
      check (list int) desc (Sorts.bubble_sort input) (List.rev expected))
    test_cases

(* Test insertion sort with the same test cases as bubble sort for consistency *)
let test_insertion_sort () =
  let test_1 =
    test_input ~label:"Sorted list" ~input:[ 1; 2; 3; 4; 5 ]
      ~expected:[ 1; 2; 3; 4; 5 ]
  in
  let test_2 =
    test_input ~label:"Reverse sorted list" ~input:[ 5; 4; 3; 2; 1 ]
      ~expected:[ 1; 2; 3; 4; 5 ]
  in
  let test_3 =
    test_input ~label:"List with duplicates" ~input:[ 3; 1; 2; 3; 2 ]
      ~expected:[ 1; 2; 2; 3; 3 ]
  in
  let test_4 =
    test_input ~label:"List with all same elements" ~input:[ 2; 2; 2; 2 ]
      ~expected:[ 2; 2; 2; 2 ]
  in
  let test_5 = test_input ~label:"Empty list" ~input:[] ~expected:[] in
  let test_cases = test_1 @ test_2 @ test_3 @ test_4 @ test_5 in
  List.iter
    (fun (desc, input, expected) ->
      check (list int) desc (Sorts.insert_sort input) (List.rev expected))
    test_cases

(* Helper function to compare sorted output with expected result *)
let sorted_equal_fn sort_fn ~input ~expected =
  check (list int) "same lists" expected (sort_fn input)

(* Test quicksort implementation
   Cases cover:
   - Random unsorted list
   - Empty list
   - Larger unsorted list
   - List with all identical elements *)
let test_quick_sort () =
  sorted_equal_fn Sorts.quick_sort ~input:[ 5; 3; 8; 1; 2 ]
    ~expected:[ 1; 2; 3; 5; 8 ];
  sorted_equal_fn Sorts.quick_sort ~input:[] ~expected:[];
  sorted_equal_fn Sorts.quick_sort ~input:[ 7; 6; 8; 4; 5; 3; 2; 1 ]
    ~expected:[ 1; 2; 3; 4; 5; 6; 7; 8 ];
  sorted_equal_fn Sorts.quick_sort ~input:[ 1; 1; 1; 1; 1 ]
    ~expected:[ 1; 1; 1; 1; 1 ]

(* Test merge sort implementation
   Cases cover:
   - Random unsorted list
   - Empty list
   - List with identical elements
   - Reverse sorted list *)
let test_merge_sort () =
  sorted_equal_fn Sorts.merge_sort ~input:[ 5; 3; 8; 1; 2 ]
    ~expected:[ 1; 2; 3; 5; 8 ];
  sorted_equal_fn Sorts.merge_sort ~input:[] ~expected:[];
  sorted_equal_fn Sorts.merge_sort ~input:[ 1; 1; 1; 1; 1 ]
    ~expected:[ 1; 1; 1; 1; 1 ];
  sorted_equal_fn Sorts.merge_sort ~input:[ 7; 6; 5; 4; 3; 2; 1 ]
    ~expected:[ 1; 2; 3; 4; 5; 6; 7 ]

(* Test heap sort implementation with array inputs
   Cases cover:
   - Empty array
   - Single element array
   - Small unsorted array
   - Larger unsorted array *)
let test_heap_sort () =
  let test_cases =
    [
      ([||], [||]);
      ([| 1 |], [| 1 |]);
      ([| 3; 1; 2; 4 |], [| 1; 2; 3; 4 |]);
      ([| 12; 11; 13; 5; 6; 7 |], [| 5; 6; 7; 11; 12; 13 |]);
    ]
  in
  List.iter
    (fun (input, expected) ->
      let sorted = Sorts.heap_sort input in
      check (array int) "heap_sort test " expected sorted)
    test_cases

(* Test timsort implementation
   Cases cover:
   - Empty list
   - Single element
   - Already sorted list
   - Reverse sorted list
   - Random unsorted list
   - List with duplicates *)
let test_tim_sort () =
  sorted_equal_fn Sorts.timsort ~input:[] ~expected:[];
  sorted_equal_fn Sorts.timsort ~input:[ 1 ] ~expected:[ 1 ];
  sorted_equal_fn Sorts.timsort ~input:[ 1; 2; 3; 4; 5 ]
    ~expected:[ 1; 2; 3; 4; 5 ];
  sorted_equal_fn Sorts.timsort ~input:[ 5; 4; 3; 2; 1 ]
    ~expected:[ 1; 2; 3; 4; 5 ];
  sorted_equal_fn Sorts.timsort ~input:[ 5; 1; 4; 2; 3 ]
    ~expected:[ 1; 2; 3; 4; 5 ];
  sorted_equal_fn Sorts.timsort ~input:[ 3; 1; 2; 3; 2; 1 ]
    ~expected:[ 1; 1; 2; 2; 3; 3 ]

(* Register all test suites *)
let () =
  run "Sorts"
    [
      ("Bubble sort", [ test_case "Bubble sort tests" `Quick test_bubble_sort ]);
      ( "Insertion sort",
        [ test_case "Insertion sort test" `Quick test_insertion_sort ] );
      ("Quick sort", [ test_case "Quick sort test" `Quick test_quick_sort ]);
      ("Merge sort", [ test_case "Merge sort test" `Quick test_merge_sort ]);
      ("Heap sort", [ test_case "Heap sort test" `Quick test_heap_sort ]);
      ("Tim sort", [ test_case "Tim sort test" `Quick test_tim_sort ]);
    ]
