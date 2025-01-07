# OCaml Search Algorithms

A collection of classic search algorithms implemented in OCaml, featuring both iterative and recursive approaches.

## Overview

This library implements five different search algorithms:
- Linear Search
- Binary Search
- Jump Search
- Exponential Search
- Interpolation Search
- Fibonacci Search

## Algorithms

### Linear Search
- **Time Complexity**: O(n)
- **Space Complexity**: O(1)
- **Description**: Sequentially checks each element until a match is found.
- **Best for**: Small lists or unsorted data.

### Binary Search
- **Time Complexity**: O(log n)
- **Space Complexity**: O(1)
- **Description**: Divides the search interval in half repeatedly.
- **Requirements**: Sorted list
- **Best for**: Large sorted datasets with random access.

### Jump Search
- **Time Complexity**: O(√n)
- **Space Complexity**: O(1)
- **Description**: Makes fixed jumps of size √n and then performs linear search.
- **Requirements**: Sorted list
- **Best for**: Sorted arrays where element access is costly.

### Exponential Search
- **Time Complexity**: O(log n)
- **Space Complexity**: O(1)
- **Description**: Searches for a range by doubling the index, then uses binary search.
- **Requirements**: Sorted list
- **Best for**: Unbounded/infinite arrays or when target is closer to the beginning.

### Interpolation Search
- **Time Complexity**:
  - Average case: O(log log n)
  - Worst case: O(n)
- **Space Complexity**: O(1)
- **Description**: Estimates target position using linear interpolation.
- **Requirements**:
  - Sorted list
  - Uniformly distributed values
  - Custom comparison and integer conversion functions
- **Best for**: Uniformly distributed sorted data.

### Fibonacci Search
- **Time Complexity**: O(log n)
- **Space Complexity**: O(1)
- **Description**: Uses Fibonacci numbers to divide search space.
- **Requirements**: Sorted list
- **Best for**: Arrays where multiplication and division operations are costly.

## Test Coverage

The test suite (`test_ocaml_searchs.ml`) provides comprehensive coverage for all implemented search algorithms:

### Test Cases
Each algorithm is tested with:
- Successful searches (finding existing elements)
- Failed searches (looking for non-existent elements)
- Edge cases where applicable

### Test Data
- **Linear/Binary Search**: Basic sorted list `[1; 3; 5; 7; 9; 11]`
- **Jump Search**: Extended sorted list `[1; 3; 5; 7; 9; 11; 13; 15; 17]`
- **Interpolation Search**: Evenly distributed list `[10; 20; 30; ...; 100]`
- **Fibonacci Search**: Fibonacci sequence `[1; 2; 3; 5; 8; 13; 21; 34; 55; 89]`