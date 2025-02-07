open Ocaml_sorts.Sorts

(**
   - This function is useful for "memory profiling "during benchmarks, especially
     when comparing algorithms that might have different memory footprints.
   - It can be used to "monitor memory consumption" before and after critical
     parts of the code (e.g. before and after running a sort operation) to
     understand the memory behavior of each algorithm.
   - For algorithms that rely heavily on memory allocation (e.g., Merge Sort,
     which involves creating new lists), this function can help track the garbage
     collector's activity and provide insights into memory efficiency.
   - Use this function to detect "excessive memory allocations" or garbage
     collections bottlenecks, which might effect performance.

   Example:

   memory_usage (); (* Before running the algorithm *)
   let _ = my_sort_function data in
   memory_usage (); (* After running the algorithm *)

 Recommendations:
  - It's particularly useful to run this function in benchmarks that compare algorithms
    with different space complexities, such as comparing an in-place sorting algorithm like
    Heap Sort to algorithms like Merge Sort, which require extra space.
  - This function is most beneficial when used with larger datasets,
    where memory allocation and GC performance have a more significant impact.
  - The output of this function can also help in fine-tuning memory management
    for performance-critical applications, or in scenarios where memory efficiency
    is as important as execution speed.

*)
let _memory_usage () =
  (* Get current garbage collector statistics *)
  let stat = Gc.stat () in
  Printf.printf "Heap words: %d\n" stat.Gc.heap_words;
  Printf.printf "Live words: %d\n" stat.Gc.live_words;
  Printf.printf "Free words: %d\n" stat.Gc.free_words;
  Printf.printf "Minor collections: %d\n" stat.Gc.minor_collections;
  Printf.printf "Major collections: %d\n" stat.Gc.major_collections

(* Generate a list of 'n' random integers between 0 and 999
   @param n The length of the list to generate
   @return A list of random integers *)
let generate_random_list n =
  let rec aux acc n =
    if n <= 0 then acc else aux (Random.int 1000 :: acc) (n - 1)
  in
  aux [] n

(* Helper function to convert lists to arrays for heap sort compatibility
   @param lst The input list
   @return An array containing the same elements as the input list *)
let list_to_array lst = Array.of_list lst

let benchmark_sorts () =
  let open Core in
  let open Core_bench in
  (* Test different input sizes to analyze time complexity *)
  let sizes = [ 100; 1000; 5000; 10000 ] in

  (* Define sorting algorithms to benchmark with their names and functions *)
  let algorithms =
    [
      ("Bubble Sort", Sorts.bubble_sort);
      ("Insertion Sort", Sorts.insert_sort);
      ("Quick Sort", Sorts.quick_sort);
      ("Merge Sort", Sorts.merge_sort);
      ("Tim Sort", Sorts.timsort);
    ]
  in

  (* Create benchmarks for each algorithm and input size combination *)
  let benchmarks =
    List.concat_map sizes ~f:(fun size ->
        List.map algorithms ~f:(fun (name, sort_fn) ->
            (* Generate fresh random list for each test to ensure fairness *)
            let random_list = generate_random_list size in
            Bench.Test.create ~name:(Printf.sprintf "%s (n=%d)" name size)
              (fun () -> ignore (sort_fn random_list))))
  in

  (* Create separate benchmarks for heap sort since it operates on arrays *)
  let heap_benchmarks =
    List.map sizes ~f:(fun size ->
        let random_list = generate_random_list size in
        let random_array = list_to_array random_list in
        Bench.Test.create ~name:(Printf.sprintf "Heap Sort (n=%d)" size)
          (fun () -> ignore (Sorts.heap_sort random_array)))
  in

  (* Combine all benchmarks and create a command *)
  Bench.make_command (benchmarks @ heap_benchmarks)

(* Entry point: Run the benchmarks *)
let () = Command_unix.run (benchmark_sorts ())
