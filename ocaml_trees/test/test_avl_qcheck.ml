open Ocaml_trees.Avl_tree

(* Test 1: Basic Insert and Search
   This test verifies that:
   - A single element can be inserted into an empty tree
   - The same element can be found using the search function
   - Uses QCheck2's integer generator to test with random integers
*)
let test_insert =
  let open AVL_Tree in
  QCheck2.Test.make
    ~name:"insearch and search"
    QCheck2.Gen.int
    (fun x ->
      let tree = empty in
      let tree' = insert ~cmp:compare x tree in
      search ~cmp:compare x tree')

(* Test 2: Insertion Preserves Search
   This test ensures that:
   - Multiple elements can be inserted into the tree
   - All previously inserted elements remain searchable
   - Uses a fixed-size list of 10 random integers
   - Verifies each element in the input list is findable after all insertions
*)
let test_insertion_search =
  let open AVL_Tree in
  let open QCheck2 in
  Test.make ~name:"insertion preserves search"
    (Gen.list_size (Gen.return 10) Gen.int)
    (fun xs ->
      let tree =
        List.fold_left (fun acc x -> insert ~cmp:compare x acc) empty xs
      in
      List.for_all (fun x -> search ~cmp:compare x tree) xs)

(* Test 3: Deletion Property
   This test validates that:
   - Elements can be properly deleted from the tree
   - After deleting all elements, none of them should be findable
   - Uses a fixed-size list of 10 random integers
   - First inserts all elements, then deletes them all
   - Verifies no element from the original list exists in the final tree
*)
let test_delete =
  let open AVL_Tree in
  let open QCheck2 in
  Test.make ~name:"delete and search"
    (Gen.list_size (Gen.return 10) Gen.int)
    (fun xs ->
      let tree =
        List.fold_left (fun acc x -> insert ~cmp:compare x acc) empty xs
      in
      let tree' =
        List.fold_left (fun acc x -> delete ~cmp:compare x acc) tree xs
      in
      List.for_all (fun x -> not (search ~cmp:compare x tree')) xs)

(* Helper Function: Balance Checker
   This recursive function verifies the AVL tree balance property:
   - Returns a tuple of (is_balanced, height)
   - A tree is balanced if:
     1. Both left and right subtrees are balanced
     2. Height difference between left and right subtrees is at most 1
   - Empty trees are considered balanced with height 0
*)
let is_balanced tree =
  let open AVL_Tree in
  let rec check_balance = function
    | Empty -> (true, 0) (* A tree with no nodes is balanced, height is 0 *)
    | Node { left; right; _ } ->
        let left_balanced, left_height = check_balance left in
        let right_balanced, right_height = check_balance right in
        (* the left, right and the absolute different in height between
           the left and the right subtrees is at most 1 *)
        let balanced =
          left_balanced && right_balanced
          && abs (left_height - right_height) <= 1
        in
        (* current height aka balance *)
        let height = 1 + max left_height right_height in
        (balanced, height)
  in
  fst (check_balance tree)

(* Test 4: AVL Balance Property
   This test ensures that:
   - The tree maintains the AVL balance property after insertions
   - Uses a fixed-size list of 10 random integers
   - Verifies that after inserting all elements:
     1. No subtree has a height difference > 1
     2. The entire tree remains balanced according to AVL rules
*)
let test_avl_property =
  let open QCheck2 in
  let open AVL_Tree in
  Test.make ~name:"AVL property"
    (Gen.list_size (Gen.return 10) Gen.int)
    (fun xs ->
      let tree =
        List.fold_left (fun acc x -> insert ~cmp:compare x acc) empty xs
      in
      is_balanced tree)

let _ =
  QCheck_runner.run_tests_main
    [ test_insert; test_insertion_search; test_delete; test_avl_property ]
