module Sorts : sig
  val bubble_sort : 'a list -> 'a list
  val insert_sort : 'a list -> 'a list
  val quick_sort : 'a list -> 'a list
  val merge_sort : 'a list -> 'a list
  val heap_sort : 'a array -> 'a array
  val timsort : 'a list -> 'a list
end = struct
  (* Performs one pass of bubble sort by comparing adjacent elements and swapping if needed *)
  let bubble_pass lst =
    let rec pass acc = function
      | [] -> List.rev acc
      | [ x ] -> List.rev (x :: acc)
      | x1 :: x2 :: tl ->
          if x1 > x2 then (* swap x1 and x2 *)
            pass (x1 :: acc) (x2 :: tl)
          else pass (x2 :: acc) (x1 :: tl)
    in
    pass [] lst

  (** Bubble Sort - O(n²)
      A simple sorting algorithm that:
      1. Repeatedly traverses the list
      2. Compares adjacent elements
      3. Swaps them if they're in wrong order
      4. Continues until no swaps are needed *)
  let bubble_sort lst =
    let rec sort lst is_sorted =
      if is_sorted then lst
      else
        let sorted = bubble_pass lst in
        (* Check if already sorted *)
        sort sorted (sorted = lst)
    in
    sort lst false

  (** Insertion Sort - O(n²)
      Builds the final sorted array one item at a time by:
      1. Taking elements from unsorted portion
      2. Finding their correct position in sorted portion
      3. Inserting them there
      Best case O(n) when list is nearly sorted *)

  (* Helper: Inserts element x into correct position in an already sorted list *)
  let rec insert x sorted =
    match sorted with
    | [] -> [ x ]
    | hd :: tl -> if x <= hd then x :: sorted else hd :: insert x tl

  let insert_sort lst =
    let rec aux acc = function
      | [] -> List.rev acc
      | hd :: tl -> aux (insert hd acc) tl
    in
    aux [] lst

  (** Quick Sort - Average O(n log n), Worst O(n²)
      A divide-and-conquer algorithm that:
      1. Selects a pivot element
      2. Partitions array into elements ≤ pivot and elements > pivot
      3. Recursively sorts the partitions
      Performance depends heavily on pivot selection *)

  (* Helper: Partitions list around pivot into two sublists *)
  let partition_pivot pivot lst =
    List.fold_right
      (fun x (left, right) ->
        if x <= pivot then (x :: left, right) else (left, x :: right))
      lst ([], [])

  let quick_sort lst =
    let rec aux acc = function
      | [] -> acc
      | pivot :: rest ->
          let left, right = partition_pivot pivot rest in
          aux (pivot :: aux acc right) left
    in
    aux [] lst

  (** Merge Sort - O(n log n)
      A stable, divide-and-conquer algorithm that:
      1. Divides list into equal halves
      2. Recursively sorts each half
      3. Merges sorted halves
      Guarantees O(n log n) but requires extra space *)

  (* Helper: Merges two sorted lists into single sorted list *)
  let rec merge left right acc =
    match (left, right) with
    | [], ys -> List.rev_append acc ys
    | xs, [] -> List.rev_append acc xs
    | x :: xs, y :: ys ->
        if x <= y then merge xs right (x :: acc) else merge left ys (y :: acc)

  (* Helper: Splits list into two roughly equal parts using alternating elements *)
  let rec split lst acc1 acc2 toggle =
    match lst with
    | [] -> (List.rev acc1, List.rev acc2)
    | x :: xs ->
        if toggle then
          (* If toggle is true, add the current element 'x' to acc1,
             and continue recursively with the rest of the list 'xs'.
             Toggle is set to false for the next recursion so that the next
             element goes to acc2. *)
          split xs (x :: acc1) acc2 (not toggle)
        else
          (* If toggle is false, add the current element 'x' to acc2,
             and continue recursively with the rest of the list 'xs'.
             Toggle is set to true for the next recursion so that the next
             element goes to acc1. *)
          split xs acc1 (x :: acc2) (not toggle)

  let rec merge_sort lst =
    match lst with
    | [] | [ _ ] -> lst
    | _ ->
        let left, right = split lst [] [] true in
        let sorted_left = merge_sort left in
        let sorted_right = merge_sort right in
        merge sorted_left sorted_right []

  (** Heap Sort - O(n log n)
      In-place sorting algorithm using binary heap that:
      1. Builds max heap from input array - O(n)
      2. Repeatedly extracts max element and restores heap property - O(n log n)
      3. Results in sorted array
      Space efficient but not stable *)

  (* Helper: Swaps two elements in array at indices i and j *)
  let swap arr i j =
    let temp = arr.(i) in
    arr.(i) <- arr.(j);
    arr.(j) <- temp

  (* Helper: Maintains max heap property for subtree rooted at index i *)
  let rec heapify arr n i =
    let largest = ref i in
    (* It is a binary tree
            0
          /  \
         1    2
        /\   / \
       3 4   5 6

       At index i = 0 (root)
       - Left child: 2 * 0 + 1 = 1
       - Right child: 2 * 0 + 2 = 2

       At index i = 1:
       - Left child: 2 * 1 + 1 = 3
       - Right child: 2 * 1 + 2 = 4

       and so on
    *)
    let left = (2 * i) + 1 in
    let right = (2 * i) + 2 in

    (* check if the left child is larger than the root *)
    if left < n && arr.(left) > arr.(!largest) then largest := left;

    (* Check if the right child is larger than the largest so far *)
    if right < n && arr.(right) > arr.(!largest) then largest := right;

    (* If the largest is not root, swap it with the largest element *)
    if !largest <> i then (
      swap arr i !largest;
      (* Recursively heapify the affected subtree *)
      heapify arr n !largest)

  (* Helper: Builds initial max heap from unordered array *)
  let build_heap arr n =
    (* Index the last non-leaf node, this node is the parent of the last two
       leaf nodes. Ex: 3
                      / \
                     9   2
                    /\   /
                   1  4  8
       - The last non-leaf node is at index:  i = (6 / 2) - 1 = 2
       - Heapify the subtree rooted at index 2. After heapify, the element at
          index 2 swaps with its child 8 (because 8 > 2)

              3
             / \
            9   8
           / \  /
           1 4  2

       - Move up to the next non-leaf node (i = 1) Heapify the subtree rooted
            at index 1 (element 9). In this case, no swap is needed because 9 >
            1 and 9 > 4.

       - Move up to the root node (i = 0) Heapify the subtree rooted at index
            0. The element 3 swaps with 9 (the largest of its children):

                9
               / \
             3    8
            / \   /
            1 4   2
    *)
    let start_idx = (n / 2) - 1 in
    (* Work bottom-up start from the last non-leaf node and moving up
       to the root *)
    for i = start_idx downto 0 do
      heapify arr n i
    done

  (* Heap sort *)
  let heap_sort arr =
    let n = Array.length arr in
    (* Step 1 : build the max heap, ensuring that the maximum element is always
       at the root of the heap. *)
    build_heap arr n;
    (* Step 2 : Extract the maximum element (root of the heap), place it at the
       end of the array, and then reduced the heap size, maintaining the heap
       property through heapify. (i = n - 1) is the last element of the array
       goes down to (i = 1) (the second element of the array)
    *)
    for i = n - 1 downto 1 do
      (* Move current root to end of the array
         The root element arry.(0) which is the largest element in the heap,
         is swapped with the element at index i (the last element of the heap).
      *)
      swap arr 0 i;
      (* Call heapify on the reduced heap *)
      heapify arr i 0
    done;
    arr

  (** TimSort - O(n log n)
      Hybrid stable sorting algorithm combining merge sort and insertion sort:
      1. Divides data into small runs (default min_run = 32)
      2. Sorts runs using insertion sort
      3. Merges runs using merge sort strategy
      Highly efficient for real-world data, especially partially sorted arrays *)

  (* Helper: Identifies and sorts runs in the input list *)
  let find_runs lst min_run =
    let rec aux lst current_run acc_run acc_all =
      match lst with
      | [] ->
          let sorted_run = insert_sort current_run in
          List.rev (sorted_run :: acc_all)
      | [ x ] ->
          let sorted_run = insert_sort (x :: current_run) in
          List.rev (sorted_run :: acc_all)
      | x :: y :: xs ->
          if List.length current_run < min_run then
            aux (y :: xs) (x :: current_run) acc_run acc_all
          else
            let sorted_run = insert_sort (x :: current_run) in
            aux (y :: xs) [ y ] acc_run (sorted_run :: acc_all)
    in
    aux lst [] [] []

  (* Helper: Tail-recursive list flattening to prevent stack overflow *)
  let rec flatten_aux lst acc =
    match lst with
    | [] -> List.rev acc
    | l :: ls -> flatten_aux ls (List.rev_append l acc)

  let flatten lst = flatten_aux lst []

  let timsort lst =
    (* min_run = 32 is a commonly used default chosen in the Python TimSort
       implementation. If sorting a much larger dataset, we might adjust the
       min_run to a slightly larger value (e.g., 64 or 128) to reduce the number
       of merges. *)
    let min_run = 32 in
    (* Step 1: divide the list into runs *)
    let runs = flatten (find_runs lst min_run) in
    (* Step 2: merge runs *)
    merge_sort runs
end
