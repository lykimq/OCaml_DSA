open File_system.File_directory
open Alcotest

(** Creates a file with the given name and content
    @param name The name of the file
    @param content The content of the file
    @return A new file record *)
let make_file name content : File_Directory.file =
  let open File_Directory in
  { name; content }

(** Creates a directory with the given name and children
    @param name The name of the directory
    @param children List of files and subdirectories
    @return A new directory node *)
let make_directory name children =
  let open File_Directory in
  Directory { name; children }

(** Tests the add_file function by:
    1. Creating an empty root directory
    2. Adding a test file to it
    3. Verifying the file exists in the directory's children *)
let test_add_file () =
  let open File_Directory in
  let dir = make_directory "root" [] in
  let file = make_file "file1.txt" "This is a test file" in
  let updated_dir =
    match add_file dir file with
    | Directory d -> d
    | _ -> failwith "Expected a directory"
  in
  (* Test if the file was added *)
  let children_names =
    List.map
      (function File f -> f.name | Directory d -> d.name)
      updated_dir.children
  in
  check (list string) "File added" [ "file1.txt" ] children_names

(** Tests the remove_file function by:
    1. Creating a directory with one file
    2. Removing that file
    3. Verifying the directory is empty *)
let test_remove_file () =
  let open File_Directory in
  let file = make_file "file1.txt" "This is a test file" in
  let dir = make_directory "root" [ File file ] in
  let updated_dir =
    match remove_node "file1.txt" dir with
    | Directory d -> d
    | _ -> failwith "Expected a directory"
  in
  check (list string) "File removed" []
    (List.map
       (function File f -> f.name | Directory d -> d.name)
       updated_dir.children)

(** Tests the remove_directory function by:
    1. Creating a directory with one subdirectory
    2. Removing that subdirectory
    3. Verifying the parent directory is empty *)
let test_remove_directory () =
  let open File_Directory in
  let subdir = make_directory "subdir" [] in
  let dir = make_directory "root" [ subdir ] in
  let updated_dir =
    match remove_node "subdir" dir with
    | Directory d -> d
    | _ -> failwith "Expected a directory"
  in
  (* Test if the sub-directory was removed *)
  check (list string) "Directory removed" []
    (List.map
       (function File f -> f.name | Directory d -> d.name)
       updated_dir.children)

(** Tests the find_directory function by:
    1. Creating a directory structure with one subdirectory
    2. Finding that subdirectory using its path
    3. Verifying the correct directory was found *)
let test_find_directory () =
  let open File_Directory in
  let subdir = make_directory "subdir" [] in
  let dir = make_directory "root" [ subdir ] in
  match find_directory [ "subdir" ] dir with
  | Some (Directory d) -> check string "Found directory" "subdir" d.name
  | _ -> fail "Directory not found"

(** Tests the find_directory function with a non-existent path by:
    1. Creating an empty directory
    2. Attempting to find a non-existent subdirectory
    3. Verifying None is returned *)
let test_find_missing_directory () =
  let open File_Directory in
  let dir = make_directory "root" [] in
  match find_directory [ "nonexist" ] dir with
  | None -> check pass "Directory Not found" () ()
  | Some _ -> fail "Unexpected directory found"

let () =
  run "File System Tests"
    [
      ( "add file",
        [ test_case "Add a file to an empty directory" `Quick test_add_file ] );
      ( "remove directory",
        [
          test_case "Remove a subdirectory" `Quick test_remove_directory;
          test_case "Remove file" `Quick test_remove_file;
        ] );
      ( "find directory",
        [
          test_case "Find a subdirectory" `Quick test_find_directory;
          test_case "Find a missing directory" `Quick
            test_find_missing_directory;
        ] );
    ]
