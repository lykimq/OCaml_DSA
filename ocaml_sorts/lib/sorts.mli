module Sorts : sig
  (** [bubble_sort lst] sorts the list [lst] using the bubble sort algorithm.
      Time complexity: O(n²)
      Space complexity: O(1)
      Stable: Yes *)
  val bubble_sort : 'a list -> 'a list

  (** [insert_sort lst] sorts the list [lst] using the insertion sort algorithm.
      Time complexity: O(n²)
      Space complexity: O(1)
      Stable: Yes
      Best for small lists or nearly sorted data *)
  val insert_sort : 'a list -> 'a list

  (** [quick_sort lst] sorts the list [lst] using the quicksort algorithm.
      Time complexity: Average O(n log n), Worst O(n²)
      Space complexity: O(log n)
      Stable: No
      Uses divide-and-conquer strategy *)
  val quick_sort : 'a list -> 'a list

  (** [merge_sort lst] sorts the integer list [lst] using the merge sort algorithm.
      Time complexity: O(n log n)
      Space complexity: O(n)
      Stable: Yes
      Note: Currently only supports integer lists *)
  val merge_sort : int list -> int list

  (** [heap_sort arr] sorts the array [arr] in-place using the heap sort algorithm.
      Time complexity: O(n log n)
      Space complexity: O(1)
      Stable: No
      Performs in-place sorting using heap data structure *)
  val heap_sort : 'a array -> 'a array

  (** [timsort lst] sorts the list [lst] using the Timsort algorithm.
      Time complexity: O(n log n)
      Space complexity: O(n)
      Stable: Yes
      Hybrid sorting algorithm combining merge sort and insertion sort *)
  val timsort : 'a list -> 'a list
end
