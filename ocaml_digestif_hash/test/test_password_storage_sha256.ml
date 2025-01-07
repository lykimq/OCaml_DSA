open Ocaml_digestif_hash.Password_storage_sha256
open Alcotest

(** Test that password hashing produces non-empty output
    This test ensures that the hash_password function returns a valid hash string
    with length greater than 0 *)
let test_hash_password () =
  let password = "my_secure_password" in
  let hashed_password = PasswordStorage.hash_password password in
  check bool "Hashed password should not be empty" true
    (String.length hashed_password > 0)

(** Test password verification with correct password
    This test verifies that a password can be successfully verified against
    its own hash value *)
let test_verify_correct_password () =
  let password = "my_secure_password" in
  let hashed_password = PasswordStorage.hash_password password in
  let result = PasswordStorage.verify_password password hashed_password in
  check bool "Password verification should succeed" true result

(** Test password verification with incorrect password
    This test ensures that verification fails when attempting to verify
    a different password against a stored hash *)
let test_verify_wrong_password () =
  let password = "my_secure_password" in
  let hashed_password = PasswordStorage.hash_password password in
  let wrong_password = "wrong_password" in
  let result = PasswordStorage.verify_password wrong_password hashed_password in
  check bool "Password verification should fail with wrong password" false
    result

(** Test handling of empty passwords
    This test verifies that the system can properly handle and hash
    empty password strings *)
let test_empty_password () =
  let empty_password = "" in
  let hashed_empty = PasswordStorage.hash_password empty_password in
  check bool "Hash of empty password should not be empty" true
    (String.length hashed_empty > 0)

(** Test hash consistency
    This test verifies that hashing the same password multiple times
    produces identical hash values, ensuring deterministic behavior *)
let test_consistent_hashing () =
  let password = "my_secure_password" in
  let hashed1 = PasswordStorage.hash_password password in
  let hashed2 = PasswordStorage.hash_password password in
  check string "Hashing the same password twice should give the same result "
    hashed1 hashed2

(** Test hash uniqueness for different passwords
    This test ensures that different passwords produce different hash values,
    verifying the uniqueness property of the hashing function *)
let test_different_password () =
  let password1 = "password_one" in
  let password2 = "password_two" in
  let hashed1 = PasswordStorage.hash_password password1 in
  let hashed2 = PasswordStorage.hash_password password2 in
  check bool "Different passwords should produce different hashes" false
    (String.equal hashed1 hashed2)

(** Collection of all test cases
    Groups all password storage test cases into a single test suite *)
let test_cases () =
  [
    test_case "Basic password hashing" `Quick test_hash_password;
    test_case "Verify correct password" `Quick test_verify_correct_password;
    test_case "Verify wrong password" `Quick test_verify_wrong_password;
    test_case "Empty password" `Quick test_empty_password;
    test_case "Consistent hashing" `Quick test_consistent_hashing;
    test_case "Different password" `Quick test_different_password;
  ]

(** Test runner entry point
    Executes all password storage tests *)
let () = run "Password Storage" [ ("Password Storage Tests", test_cases ()) ]
