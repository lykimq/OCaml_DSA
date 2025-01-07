# OCaml Sorting Algorithms Implementation

This project implements and benchmarks various sorting algorithms in OCaml, comparing their performance characteristics and memory usage patterns.

## Implemented Algorithms

| Algorithm | Time Complexity | Space Complexity | Stable | Notes |
|-----------|----------------|------------------|--------|-------|
| Bubble Sort | O(n²) | O(1) | Yes | Simple implementation, efficient for tiny lists |
| Insertion Sort | O(n²) | O(1) | Yes | Efficient for small or nearly sorted lists |
| Quick Sort | O(n log n)* | O(log n) | No | Uses divide-and-conquer strategy |
| Merge Sort | O(n log n) | O(n) | Yes | Currently optimized for integer lists |
| Heap Sort | O(n log n) | O(1) | No | In-place sorting using heap data structure |
| Tim Sort | O(n log n) | O(n) | Yes | Hybrid of merge sort and insertion sort |

\* Quick Sort's worst-case time complexity is O(n²)


## Benchmarking

The project includes two different benchmarking implementations:

### 1. Core_bench Implementation
Uses Jane Street's Core_bench library for comprehensive benchmarking with statistical analysis.

### 2. Bechamel Implementation
Uses the Bechamel library to measure:
- Major/Minor memory allocations
- Monotonic clock (wall-clock time)


## Test Parameters

- Input sizes: 100, 1,000, 5,000, and 10,000 elements
- Data type: Random integers (0-999)
- Each algorithm is tested with identical input data
- Multiple iterations to ensure statistical significance

## Memory Profiling

The implementation includes memory profiling capabilities through the `memory_usage` function, which tracks:
- Heap words
- Live words
- Free words
- Minor/Major garbage collections


## Algorithm Selection Guide

- **Small Lists (<50 elements)**: Insertion Sort
- **Nearly Sorted Data**: Insertion Sort or Tim Sort
- **Memory Constrained**: Heap Sort
- **Stability Required**: Merge Sort or Tim Sort
- **General Purpose**: Quick Sort
- **Guaranteed Performance**: Merge Sort

## Contributing

Feel free to contribute by:
1. Opening issues for bugs or enhancement suggestions
2. Submitting pull requests with improvements
3. Adding new sorting algorithms
4. Enhancing the benchmarking suite
