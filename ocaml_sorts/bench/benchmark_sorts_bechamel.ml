open Bechamel
open Ocaml_sorts.Sorts
open Toolkit

(* Helper function to generate test data *)
let generate_random_list n =
  let rec aux acc n =
    if n <= 0 then acc else aux (Random.int 1000 :: acc) (n - 1)
  in
  aux [] n

let benchmark_sorts () =
  (* Define different input sizes for benchmarking *)
  let sizes = [ 100; 1000; 5000; 10000 ] in

  (* Helper function to create a benchmark test for a sorting algorithm
     - name: identifier for the sort algorithm and input size
     - sort_fn: the sorting function to benchmark
     - n: size of input data *)
  let test_sort name sort_fn n =
    let data = generate_random_list n in
    let test = Staged.stage (fun () -> ignore (sort_fn data)) in
    Test.make ~name test
  in

  (* Create benchmark tests for each sorting algorithm at each input size *)
  let tests =
    List.concat_map
      (fun size ->
        [
          test_sort
            (Printf.sprintf "Bubble Sort (n=%d)" size)
            Sorts.bubble_sort size;
          test_sort
            (Printf.sprintf "Insertion Sort (n=%d)" size)
            Sorts.insert_sort size;
          test_sort
            (Printf.sprintf "Quick Sort (n=%d)" size)
            Sorts.quick_sort size;
          test_sort
            (Printf.sprintf "Merge Sort (n=%d)" size)
            Sorts.merge_sort size;
          test_sort (Printf.sprintf "Tim Sort (n=%d)" size) Sorts.timsort size;
          test_sort
            (Printf.sprintf "Heap Sort (n=%d)" size)
            (fun lst -> Array.to_list (Sorts.heap_sort (Array.of_list lst)))
            size;
        ])
      sizes
  in

  (* Configure the benchmark parameters:
     - instances: what metrics to measure (memory allocation and time)
     - cfg: benchmark configuration (time limit and quota)
     - ols: Ordinary Least Squares regression analysis configuration *)
  let instances =
    Instance.[
      minor_allocated;   (* Young generation allocations *)
      major_allocated;   (* Old generation allocations *)
      monotonic_clock    (* Wall clock time *)
    ]
  in
  let cfg = Benchmark.cfg ~limit:2000 ~quota:(Time.second 2.0) () in
  (* Configure OLS analysis with bootstrapping disabled and R² calculation enabled *)
  let ols =
    Analyze.ols ~bootstrap:0 ~r_square:true ~predictors:Measure.[| run |]
  in

  (* Execute the benchmarks and collect raw measurements *)
  let raw_results =
    Benchmark.all cfg instances
      (Test.make_grouped ~name:"sorts" ~fmt:"%s %s" tests)
  in

  (* Analyze the raw results using OLS regression *)
  let results =
    List.map (fun instance -> Analyze.all ols instance raw_results) instances
  in

  (* Merge results from different metrics into a single dataset *)
  let results = Analyze.merge ols instances results in
  (results, raw_results)

(* Helper function to create a visual representation of benchmark results *)
let img (window, results) =
  Bechamel_notty.Multiple.image_of_ols_results ~rect:window
    ~predictor:Measure.run results

(* Main function:
   1. Determine terminal window size
   2. Run benchmarks
   3. Display results as a terminal-based visualization *)
let () =
  let open Notty_unix in
  let window =
    match winsize Unix.stdout with
    | Some (w, h) -> { Bechamel_notty.w; h }
    | None -> { Bechamel_notty.w = 80; h = 1 }
  in
  let results, _ = benchmark_sorts () in
  img (window, results) |> eol |> output_image
