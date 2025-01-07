open Ocaml_trees.Patricia_tree
open Alcotest

(** Test the insertion functionality of the Patricia tree
    - Creates an empty tree
    - Inserts three strings: "comet", "commute", "com"
    - Verifies that the tree contains all inserted strings in lexicographical order *)
let test_insert () =
  let open Patricia_Tree in
  let empty_tree = None in
  let tree = ref empty_tree in
  tree := insert "comet" !tree;
  tree := insert "commute" !tree;
  tree := insert "com" !tree;
  (* Convert to list and check the expected order *)
  let result = to_list !tree in
  check (list string) "check insertion "
    [ "com"; "comet"; "commute" ]
    (List.sort compare result)

(** Test the find functionality of the Patricia tree
    - Creates a tree with three strings: "comet", "commute", "com"
    - Verifies that each inserted string can be found in the tree
    - Uses boolean checks to ensure presence of each string *)
let test_find () =
  let open Patricia_Tree in
  let tree = ref None in
  tree := insert "comet" !tree;
  tree := insert "commute" !tree;
  tree := insert "com" !tree;
  (* Check that the strings are found *)
  check bool "found comet" true (find "comet" !tree);
  check bool "found commute" true (find "commute" !tree);
  check bool "found com" true (find "com" !tree)

(** Test the deletion functionality of the Patricia tree
    - Creates a tree with three strings: "comet", "commute", "com"
    - Deletes "comet" from the tree
    - Verifies remaining strings are present in correct order
    - Confirms that deleted string "comet" cannot be found *)
let test_delete () =
  let open Patricia_Tree in
  let tree = ref None in
  tree := insert "comet" !tree;
  tree := insert "commute" !tree;
  tree := insert "com" !tree;
  tree := delete "comet" !tree;
  (* Convert to list and check the expected order *)
  let result = to_list !tree in
  check (list string) "check deletion" [ "com"; "commute" ]
    (List.sort compare result);
  (* Check that the deleted string is not found *)
  check bool "find 'comet' after deletion" false (find "comet" !tree)

(** Test the empty tree functionality
    - Verifies that an empty tree contains no strings (empty list)
    - Confirms that searching for any string in an empty tree returns false *)
let test_empty () =
  let open Patricia_Tree in
  let tree = None in
  (* An empty tree should have no string *)
  check (list string) "check empty tree" [] (to_list tree);
  (* Nothing shoudl be found *)
  check bool "find in empty tree" false (find "anything" tree)

let () =
  run "Patricia Tree Tests"
    [
      ("Insert Tests", [ test_case "Insert and List" `Quick test_insert ]);
      ("Find Tests", [ test_case "Find" `Quick test_find ]);
      ("Delete Tests", [ test_case "Delete" `Quick test_delete ]);
      ("Empty Tests", [ test_case "Empty" `Quick test_empty ]);
    ]
