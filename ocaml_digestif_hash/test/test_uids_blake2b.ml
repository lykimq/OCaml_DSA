open Ocaml_digestif_hash.Uids_blake2b
open Alcotest

(** Tests that a UID is generated and is non-empty for a given input *)
let test_generate_uid () =
  let data = "user@example.com" in
  let uid = UniqueIdentifier.generate_uid data in
  check bool "UID should not be empty" true (String.length uid > 0)

(** Verifies that generating UIDs for the same input produces consistent results *)
let test_consistent_uid_generation () =
  let data = "user@example.com" in
  let uid1 = UniqueIdentifier.generate_uid data in
  let uid2 = UniqueIdentifier.generate_uid data in
  check string "Hashing the same data twice should give the same UID" uid1 uid2

(** Ensures that different input data produces different UIDs *)
let test_different_data_different_uids () =
  let data1 = "user@example.com" in
  let data2 = "file1.txt: 10KB, created 2024-09-20" in
  let uid1 = UniqueIdentifier.generate_uid data1 in
  let uid2 = UniqueIdentifier.generate_uid data2 in
  check bool "Different data should generate different UIDs" false
    (String.equal uid1 uid2)

(** Tests that a UID can be verified against its original input data *)
let test_verify_correct_uid () =
  let data = "user@example.com" in
  let uid = UniqueIdentifier.generate_uid data in
  let result = UniqueIdentifier.verify_uid data uid in
  check bool "Correct data-UID pair should verify successfully" true result

(** Verifies that UIDs fail verification when checked against incorrect data *)
let test_verify_incorrect_uid () =
  let data = "user@example.com" in
  let uid = UniqueIdentifier.generate_uid data in
  let wrong_data = "wrong@example.com" in
  let result = UniqueIdentifier.verify_uid wrong_data uid in
  check bool "Incorrect data-UID pair should fail verification" false result

(** Tests UID generation and verification with empty input data *)
let test_empty_data_uid () =
  let empty_data = "" in
  let uid = UniqueIdentifier.generate_uid empty_data in
  check bool "UID for empty data should not be empty" true
    (String.length uid > 0);
  let result = UniqueIdentifier.verify_uid "" uid in
  check bool "Empty data should verify successfully with its own UID" true
    result

(** Tests the UID shortening functionality with various lengths *)
let test_shorten_uid () =
  let uid = UniqueIdentifier.generate_uid "user@example.com" in
  Printf.printf "Generated UID length: %d\n" (String.length uid);
  let shortened = UniqueIdentifier.shorten_uid uid 8 in
  check int "Shortened UID should have the correct length" 8
    (String.length shortened);
  let shortened_longer = UniqueIdentifier.shorten_uid uid 100 in
  check int
    "Shortening UID to length greater than original should return full UID" 100
    (String.length shortened_longer)

(** Validates the UID format checking functionality *)
let test_is_valid_uid () =
  let valid_uid = UniqueIdentifier.generate_uid "user@example.com" in
  check bool "Generate UID should be valid" true
    (UniqueIdentifier.is_valid_uid valid_uid);
  let invalid_uid = "zzzzaaaa" in
  check bool "Non-hexadecimal UID should be invalid" false
    (UniqueIdentifier.is_valid_uid invalid_uid);
  let empty_uid = "" in
  check bool "Empty string should be invalid UID" false
    (UniqueIdentifier.is_valid_uid empty_uid)

(** Tests the functionality to combine multiple UIDs into a single UID *)
let test_combine_uids () =
  let uid1 = UniqueIdentifier.generate_uid "user@example.com" in
  let uid2 = UniqueIdentifier.generate_uid "file_metadata" in
  let combine_uid = UniqueIdentifier.combine_uids [ uid1; uid2 ] in
  check bool "Combined UID should generate a non-empty UID" true
    (String.length combine_uid > 0)

(** Tests generating UIDs from multiple input fields *)
let test_generate_uid_from_multiple_fields () =
  let uid_fields =
    UniqueIdentifier.generate_uid_from_multiple_fields
      [ "user@example.com"; "user123" ]
  in
  check bool "Generated UID from multiple fields should not be empty" true
    (String.length uid_fields > 0);
  let uid_fields_diff =
    UniqueIdentifier.generate_uid_from_multiple_fields
      [ "user@example.com"; "user124" ]
  in
  check bool "Different fields should generate different UIDs" false
    (String.equal uid_fields uid_fields_diff)

let test_uid_generation () =
  [
    test_case "Generate UID for data" `Quick test_generate_uid;
    test_case "Consistent UID generation" `Quick test_consistent_uid_generation;
    test_case "Different data different UIDs" `Quick
      test_different_data_different_uids;
    test_case "Verify correct UID" `Quick test_verify_correct_uid;
    test_case "Verify incorrect UID" `Quick test_verify_incorrect_uid;
    test_case "Hashing and verifying empty data" `Quick test_empty_data_uid;
    test_case "Shorten UID" `Quick test_shorten_uid;
    test_case "Check valid UID" `Quick test_is_valid_uid;
    test_case "Combine UIDs" `Quick test_combine_uids;
    test_case "Generate UID from multiple fields" `Quick
      test_generate_uid_from_multiple_fields;
  ]

let () =
  run "UniqueIdentifier" [ ("UID Generation Testse", test_uid_generation ()) ]
