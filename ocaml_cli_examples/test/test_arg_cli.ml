(* Import required modules *)
open Alcotest  (* Testing framework *)
open Bos       (* Basic OS interaction *)
open Rresult   (* Result handling *)

(* Helper function to run shell commands and handle their output
   Returns the command output as string or fails with error message *)
let run_cmd cmd =
  match OS.Cmd.run_out cmd |> OS.Cmd.out_string with
  | Ok (output, _) -> output
  | Error (`Msg e) -> failwith ("Command failed: " ^ e)

(* Test the greeting functionality
   Executes the CLI with "--g" flag and checks if it properly greets the user *)
let test_greet () =
  let args = [ "Gwen" ] in
  let start_cmd =
    Bos.Cmd.(v "dune" % "exec" % "arg_cli" % "--" % "--g" %% of_list args)
    (* Note: "--" separates dune args from our program args *)
  in
  let output = run_cmd start_cmd in
  check string "check greet output" output "Hello, Gwen"

(* Test the goodbye functionality
   Executes the CLI with "--b" flag and checks if it properly says goodbye *)
let test_goodbye () =
  let args = [ "Gwen" ] in
  let start_cmd =
    Bos.Cmd.(v "dune" % "exec" % "arg_cli" % "--" % "--b" %% of_list args)
    (* Note: "--" separates dune args from our program args *)
  in
  let output = run_cmd start_cmd in
  check string "check greet output" output "Goodbye, Gwen"

(* Main test runner
   Registers and executes all test cases under the "OASIS CLI Tests" suite *)
let () =
  run "OASIS CLI Tests"
    [
      ( "Greet and Goodbye tests",
        [
          test_case "greeting" `Quick test_greet;
          test_case "goodbye" `Quick test_goodbye;
        ] );
    ]
