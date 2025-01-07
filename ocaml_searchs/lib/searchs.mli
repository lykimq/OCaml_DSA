module Searchs : sig
  (** [linear_search lst x] searches for element [x] in list [lst] using linear search.
      Time complexity: O(n), where n is the length of the list.
      Space complexity: O(1) *)
  val linear_search : 'a list -> 'a -> bool

  (** [binary_search lst x] searches for element [x] in sorted list [lst] using binary search.
      Requires: The input list must be sorted.
      Time complexity: O(log n), where n is the length of the list.
      Space complexity: O(1) *)
  val binary_search : 'a list -> 'a -> bool

  (** [jump_search lst x] searches for element [x] in sorted list [lst] using jump search.
      Requires: The input list must be sorted.
      Time complexity: O(√n), where n is the length of the list.
      Space complexity: O(1) *)
  val jump_search : 'a list -> 'a -> bool

  (** [exponential_search lst x] searches for element [x] in sorted list [lst] using exponential search.
      Requires: The input list must be sorted.
      Time complexity: O(log n), where n is the length of the list.
      Space complexity: O(1)
      Note: Particularly useful for unbounded searches *)
  val exponential_search : 'a list -> 'a -> bool

  (** [interpolation_search ~compare ~to_int lst x] searches for element [x] in sorted list [lst]
      using interpolation search.
      Requires:
      - The input list must be sorted
      - [compare] function to compare two elements
      - [to_int] function to convert elements to integers for interpolation
      Time complexity: O(log log n) average case, O(n) worst case
      Space complexity: O(1) *)
  val interpolation_search :
    compare:('a -> 'a -> int) -> to_int:('a -> int) -> 'a list -> 'a -> bool

  (** [fibonacci_search lst x] searches for element [x] in sorted list [lst] using Fibonacci search.
      Requires: The input list must be sorted.
      Time complexity: O(log n), where n is the length of the list.
      Space complexity: O(1)
      Note: Uses Fibonacci numbers to divide the array, can be more efficient than binary search
            in practice due to using only addition and subtraction *)
  val fibonacci_search : 'a list -> 'a -> bool
end
