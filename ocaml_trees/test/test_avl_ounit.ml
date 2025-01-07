open OUnit2
open Ocaml_trees.Avl_tree

(* Test that rotating an empty tree to the right returns an empty tree *)
let test_right_rotate_empty _ =
  let open AVL_Tree in
  let tree = empty in
  assert_equal tree (rotate_right tree)

(* Test right rotation of a left-heavy tree:
   Initial state:     After rotation:
        30      =>        20
        /                 /\
       20               10 30
       /\
      10               *)
let test_right_rotate _ =
  let open AVL_Tree in
  let tree =
    make_node 30 (make_node 20 (make_node 10 empty empty) empty) empty
  in
  let expected_tree =
    make_node 20 (make_node 10 empty empty) (make_node 30 empty empty)
  in
  assert_equal expected_tree (rotate_right tree)

(* Test left rotation of a right-heavy tree:
   Initial state:     After rotation:
        10      =>        20
         \              /\
          20          10 30
           \
           30         *)
let test_left_rotate _ =
  let open AVL_Tree in
  let tree =
    make_node 10 empty (make_node 20 empty (make_node 30 empty empty))
  in
  let expected_tree =
    make_node 20 (make_node 10 empty empty) (make_node 30 empty empty)
  in
  assert_equal expected_tree (rotate_left tree)

(* Test inserting elements into the AVL tree.
   Inserts 10, 20, 30 which should trigger rotations
   to maintain balance, resulting in 20 as root *)
let test_insert _ =
  let open AVL_Tree in
  let tree = empty in
  let tree = insert ~cmp:compare 10 tree in
  let tree = insert ~cmp:compare 20 tree in
  let tree = insert ~cmp:compare 30 tree in
  let expected_tree =
    make_node 20 (make_node 10 empty empty) (make_node 30 empty empty)
  in
  assert_equal expected_tree tree

(* Test searching for elements in the AVL tree.
   Creates a tree with elements 10, 20, 30 and
   verifies that 20 exists but 40 doesn't *)
let test_search _ =
  let open AVL_Tree in
  let tree =
    insert ~cmp:compare 10
      (insert ~cmp:compare 20 (insert ~cmp:compare 30 empty))
  in
  assert_equal true (search ~cmp:compare 20 tree);
  assert_equal false (search ~cmp:compare 40 tree)

(* Test deleting elements from the AVL tree.
   Creates a tree with 10, 20, 30, deletes 20,
   and verifies the resulting structure and that
   20 no longer exists in the tree *)
let test_delete _ =
  let open AVL_Tree in
  let tree =
    insert ~cmp:compare 10
      (insert ~cmp:compare 20 (insert ~cmp:compare 30 empty))
  in
  let tree = delete ~cmp:compare 20 tree in
  let expected_tree = make_node 30 (make_node 10 empty empty) empty in
  assert_equal expected_tree tree;
  assert_equal false (search ~cmp:compare 20 tree)

let suite =
  "AVL Tree tests"
  >::: [
         "test_right_rotate_empty" >:: test_right_rotate_empty;
         "test_right_rotate" >:: test_right_rotate;
         "test_left_rotate" >:: test_left_rotate;
         "test_insert" >:: test_insert;
         "test_search" >:: test_search;
         "test_delete" >:: test_delete;
       ]

let () = run_test_tt_main suite
