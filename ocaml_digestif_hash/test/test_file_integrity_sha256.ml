open Ocaml_digestif_hash.File_integrity_sha256
open Alcotest

(* Helper functions *)

(* Creates a new file with the given filename and content
   @param filename The name of the file to create
   @param content The content to write to the file *)
let create_test_file filename content =
  let oc = open_out filename in
  output_string oc content;
  close_out oc

(* Modifies an existing file with new content
   @param filename The name of the file to modify
   @param new_content The new content to write to the file *)
let modify_test_file filename new_content =
  create_test_file filename new_content

(* Safely removes a file if it exists
   @param filename The name of the file to remove *)
let remove_file filename = try Sys.remove filename with Sys_error _ -> ()

(* Test Cases *)

(* Tests that file integrity verification passes when the file hasn't been modified
   Creates a file, generates its hash, saves it, and verifies the integrity *)
let test_file_integrity_verified () =
  let file_to_check = "test_file.txt" in
  let hash_store_file = "test_hash.txt" in
  create_test_file file_to_check "This is the original content.";

  (* Step 1: Generate and save hash *)
  let file_hash = FileIntegrityChecker.sha256_hash_file file_to_check in
  FileIntegrityChecker.save_hash file_hash hash_store_file;

  (* Step 2: verify integrity (should pass) *)
  let result =
    FileIntegrityChecker.verify_file_integrity file_to_check hash_store_file
  in
  check bool "File integrity is verified" true result;
  (* clean up *)
  remove_file file_to_check;
  remove_file hash_store_file

(* Tests that file integrity verification fails when the file has been modified
   Creates a file, generates its hash, modifies the file, and verifies the integrity *)
let test_file_integrity_failed () =
  (* Prepare test file *)
  let file_to_check = "test_file.txt" in
  let hash_store_file = "test_hash.txt" in
  create_test_file file_to_check "This is the original content.";
  (* Step 1: generate and save hash *)
  let file_hash = FileIntegrityChecker.sha256_hash_file file_to_check in
  FileIntegrityChecker.save_hash file_hash hash_store_file;

  (* Modify file to simulate tampering *)
  modify_test_file file_to_check "This is the modified content.";

  (* Step 2: Verify integrity (should fail) *)
  let result =
    FileIntegrityChecker.verify_file_integrity file_to_check hash_store_file
  in
  check bool "File integrity check failed due to modification" false result;
  (* clean up *)
  remove_file file_to_check;
  remove_file hash_store_file

(* Tests that attempting to verify a non-existent file raises the appropriate error
   Attempts to verify integrity of a file that doesn't exist *)
let test_file_not_found () =
  (* Test with a missing file *)
  let file_to_check = "non_existent_file.txt" in
  let hash_store_file = "test_hash.txt" in

  (* Attempt to verify file integrity - should raise Sys_error *)
  let test () =
    let _ =
      FileIntegrityChecker.verify_file_integrity file_to_check hash_store_file
    in
    ()
  in
  check_raises "File not found should raise Sys_error"
    (Sys_error "non_existent_file.txt: No such file or directory") test;
  (* clean up *)
  remove_file file_to_check;
  remove_file hash_store_file

(* Tests that hash computation and storage works correctly
   Creates a file, computes its hash, stores it, and verifies the stored hash matches
   a fresh computation *)
let test_correct_hash_computation () =
  (* Prepare test file *)
  let file_to_check = "test_file.txt" in
  let hash_store_file = "test_hash.txt" in
  let content = "This is the originia content." in
  create_test_file file_to_check content;

  (* Step 1: generate and save hash *)
  let file_hash = FileIntegrityChecker.sha256_hash_file file_to_check in
  FileIntegrityChecker.save_hash file_hash hash_store_file;

  (* Read the hash back and verify it is correct *)
  let stored_hash = FileIntegrityChecker.read_stored_hash hash_store_file in
  let expected_hash =
    FileIntegrityChecker.sha256_hash_file file_to_check
    |> FileIntegrityChecker.hash_to_hex
  in
  check string "Correct hash stored and computed" expected_hash stored_hash;
  (* clean up *)
  remove_file file_to_check;
  remove_file hash_store_file

(* Main test runner
   Registers and runs all test cases *)
let () =
  run "File Integrity Checker Tests"
    [
      ( "file_integrity",
        [
          test_case "File integrity verified" `Quick
            test_file_integrity_verified;
          test_case "File integrity failed" `Quick test_file_integrity_failed;
          test_case "File not found" `Quick test_file_not_found;
          test_case "Correct hash computation and storage" `Quick
            test_correct_hash_computation;
        ] );
    ]
