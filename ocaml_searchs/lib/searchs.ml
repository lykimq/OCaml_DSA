module Searchs : sig
  val linear_search : 'a list -> 'a -> bool
  val binary_search : 'a list -> 'a -> bool
  val jump_search : 'a list -> 'a -> bool
  val exponential_search : 'a list -> 'a -> bool

  val interpolation_search :
    compare:('a -> 'a -> int) -> to_int:('a -> int) -> 'a list -> 'a -> bool

  val fibonacci_search : 'a list -> 'a -> bool
end = struct
  (** Linear search: checks each element sequentially until the target is found. *)
  let linear_search lst target = List.exists (fun x -> x = target) lst

  (** Binary search: works on sorted lists by repeatedly halving the search
      range. *)
  let binary_search lst target =
    let rec aux left right =
      if left > right then false
      else
        let mid = (left + right) / 2 in
        let mid_val = List.nth lst mid in
        if mid_val = target then true
        else if mid_val > target then aux left (mid - 1)
        else (* Search on the right part *)
          aux (mid + 1) right
    in
    aux 0 (List.length lst - 1)

  (** Jump search: makes jumps of size sqrt(n) until the block containing the
      target is found, then performs linear search within that block. *)
  let jump_search lst target =
    let n = List.length lst in
    (* For example, with n = 100, we will jump in blocks of 10 elements. *)
    let step = int_of_float (sqrt (float_of_int n)) in
    let rec search start =
      if start >= n then false
      else if List.nth lst start = target then true
      else if
        (* the target is in the previous block. *)
        List.nth lst start > target
      then
        linear_search
          (List.filteri
             (fun i _ ->
               (* [start - step + 1]: substract from start to step, +1 ensures
                    that we don't include the element that is at the [start -
                    step], because this element was already checked when we made
                    the previous jump.

                    [i < start]: ensure that we stop checking just before the
                  [start] index. *)
               i >= start - step + 1 && i < start)
             lst)
          target
      else search (start + step)
    in
    search step

  (** Exponential search: grows the range exponentially (by powers of 2) until finding
      an upper bound for the target, then performs binary search within that range. *)
  let list_sub lst start len =
    let rec aux lst start len acc =
      match (lst, start) with
      | _, _ when len <= 0 -> List.rev acc
      | [], _ -> List.rev acc
      | _x :: xs, 0 ->
          (* when start is 0, start addding elements to the acc *)
          aux xs 0 (len - 1) (List.hd lst :: acc)
      | _ :: xs, n ->
          (* skip elements until we reach the starting index *)
          aux xs (n - 1) len acc
    in
    aux lst start len []

  let exponential_search lst target =
    let n = List.length lst in
    (* If the first element is the target, true *)
    if List.nth lst 0 = target then true
    else
      (* Find the range where the target might be located. The range grows
         exponetially, doubling the bound at each step. *)
      let rec find_range bound =
        if bound < n && List.nth lst bound <= target then find_range (bound * 2)
        else
          let left = bound / 2 in
          let right = min (bound - 1) (n - 1) in
          binary_search (list_sub lst left (right - left + 1)) target
      in
      find_range 1

  (*** Interpolation search: estimates the target's position using linear interpolation
       based on the values at the endpoints of the current range.

       Example:
       List: [10; 20; 30; 40; 50; 60; 70; 80; 90]
       Target: 65

       Initial calculation:
       - Range: [10 (low) ... 90 (high)]
       - Position = low + ((target - low_val) * (high - low)) / (high_val - low_val)
       - Position = 0 + ((65 - 10) * (8 - 0)) / (90 - 10)
       - Position ≈ 5.5 (rounded to 5)

       This estimates the target should be near index 5 (value 60)
  *)
  let interpolation_search ~compare ~to_int lst target =
    let n = List.length lst in
    let rec aux low high =
      if
        low <= high
        && compare target (List.nth lst low) >= 0
        && compare target (List.nth lst high) <= 0
      then
        let low_val = List.nth lst low in
        let high_val = List.nth lst high in
        let diff_target_low = to_int target - to_int low_val in
        let diff_range = to_int high_val - to_int low_val in
        if diff_range = 0 then compare low_val target = 0
        else
          let pos = low + (diff_target_low * (high - low) / diff_range) in
          let pos = min (max low pos) high in
          if compare (List.nth lst pos) target = 0 then true
          else if compare (List.nth lst pos) target < 0 then aux (pos + 1) high
          else aux low (pos - 1)
      else false
    in
    aux 0 (n - 1)

  (** Fibonacci search: uses Fibonacci numbers to divide the search space into uneven sections.
      Similar to binary search but uses the golden ratio (≈1.618) for splits instead of 2.

      Example for list of length 11:
      1. Find largest Fibonacci number <= 11: 8
      2. Initial Fibonacci numbers: fib_m=8, fib_m1=5, fib_m2=3
      3. Compare at index fib_m2 (3)
      4. Based on comparison:
         - If target is larger: offset += fib_m2
         - Update Fibonacci numbers by shifting down sequence

      The sequence of Fibonacci numbers (fib_m, fib_m1, fib_m2) is used to determine
      split points and gradually narrows the search range.
  *)
  let fibonacci_search lst target =
    let n = List.length lst in
    (* Precompute Fib numbers until the largest one is smaller than [n] *)
    let rec fib_gen fibs =
      let f1 = List.hd fibs in
      let f2 = List.hd (List.tl fibs) in
      if f1 + f2 > n then fibs else fib_gen ((f1 + f2) :: fibs)
    in
    (* [1; 1] as initial list is that it corresponds to the first 2 Fib numbers.
       F(0) = 0; F(1) = 1; F(2) = F(1) + F(0) = 1 *)
    let fibs = fib_gen [ 1; 1 ] in
    let rec search offset fib_m fib_m1 fib_m2 =
      if fib_m < 1 then false
      else
        let idx = min (offset + fib_m2) (n - 1) in
        (* Using [List.nth_opt] avoid the program crashing on out-of-bound
           access, which can also be handled without using exception handling.
        *)
        match List.nth_opt lst idx with
        | None -> false
        | Some v ->
            if v = target then true
            else if v < target then
              (* Search in the right part of the list *)
              search (offset + fib_m2) (fib_m - fib_m1) fib_m1 fib_m2
            else
              (* Search in the left part of the list *)
              search offset fib_m1 fib_m2 (fib_m1 - fib_m2)
    in
    match fibs with
    | [] | [ _ ] -> false
    | fib_m :: fib_m1 :: fib_m2 :: _ -> search 0 fib_m fib_m1 fib_m2
    | _ -> false
end
