# OCaml DSA (Data Structures and Algorithms)

This repository serves as both a learning resource and a practical toolkit for OCaml developers, featuring implementations of classic data structures and algorithms with a functional programming approach. Each implementation emphasizes OCaml's strong type system and pattern matching capabilities.

## 🌟 Features

### 📁 File System (`file_system/`)
### 📁 Search Algorithms (`ocaml_searchs/`)
### 📁 Sorting Algorithms (`ocaml_sorts/`)
### 📁 Tree Data Structures (`ocaml_trees/`)
### 📁 Graph Algorithms (`ocaml_graphs/`)
### 📁 Cryptographic Utilities (`ocaml_digestif_hash/`)
### 📁 Network Programming (`ocaml_tcp_client_server/`)
### 📁 Command Line Interface (`ocaml_cli_examples/`)

### Testing Framework
1. **OUnit Tests**
2. **QCheck Property-based Tests**
3. **Alcotest Tests**

### Benchmarking
- **Core_bench**: Simple benchmarking library
- **Bechamel**: Comprehensive benchmarking framework
- **OCaml Benchmark**: Comprehensive benchmarking framework
- **OCaml Bench**: Comprehensive benchmarking framework

## 📁 File System (`file_system/`)
A custom file system implementation in OCaml using balanced tree data structures, providing efficient file organization and manipulation.

#### Core Components
1. **Directory Management** (`file_directory.ml`)
   - Directory structure implementation
   - Error handling for directory operations
   - Directory search and traversal functions
   - Type-safe directory manipulation

2. **AVL Tree Implementation** (`file_system_avl_tree_balance.ml`)
   - Self-balancing binary search tree
   - Automatic height balancing
   - Node removal with rebalancing
   - Efficient search operations
   - Height-balanced structure maintenance

3. **Simple Balance Implementation** (`file_system_simple_balance.ml`)
   - Basic balancing mechanism
   - File addition with balance maintenance
   - Simplified balancing algorithm
   - Alternative to AVL for less demanding use cases

4. **String Utilities** (`string_conversion.ml`)
   - String conversion operations
   - Format handling for file system entries
   - Path string manipulation
   - String representation of file system structure

#### Features
- Two balancing strategies (AVL and Simple)
- Type-safe file system operations
- Efficient directory searching
- Robust error handling
- Path manipulation utilities
- Modular design for easy extension

### 🔍 Search Algorithms (`ocaml_searchs/`)
A collection of classic and advanced search algorithms implemented in OCaml, providing various approaches for efficient data searching.

#### Implemented Algorithms

1. **Linear Search**
   - Simple sequential search algorithm
   - Time Complexity: O(n)
   - Best for small lists or unsorted data
   ```ocaml
   let found = Searchs.linear_search [1; 2; 3; 4; 5] 3  (* returns true *)
   ```

2. **Binary Search**
   - Efficient search for sorted lists
   - Time Complexity: O(log n)
   - Requires sorted input
   ```ocaml
   let found = Searchs.binary_search [1; 2; 3; 4; 5] 3  (* returns true *)
   ```

3. **Jump Search**
   - Block-jumping search algorithm
   - Time Complexity: O(√n)
   - Good for sorted arrays where jumping ahead is cheaper than accessing elements
   ```ocaml
   let found = Searchs.jump_search [1; 2; 3; 4; 5] 3  (* returns true *)
   ```

4. **Exponential Search**
   - Finds range exponentially then performs binary search
   - Time Complexity: O(log n)
   - Useful for unbounded/infinite arrays
   ```ocaml
   let found = Searchs.exponential_search [1; 2; 3; 4; 5] 3  (* returns true *)
   ```

5. **Interpolation Search**
   - Position-based search algorithm
   - Time Complexity: O(log log n) average case, O(n) worst case
   - Best for uniformly distributed sorted data
   ```ocaml
   let found = Searchs.interpolation_search
     ~compare:Int.compare
     ~to_int:(fun x -> x)
     [1; 2; 3; 4; 5]
     3  (* returns true *)
   ```

6. **Fibonacci Search**
   - Divides array using Fibonacci numbers
   - Time Complexity: O(log n)
   - Uses Fibonacci sequence for probing
   ```ocaml
   let found = Searchs.fibonacci_search [1; 2; 3; 4; 5] 3  (* returns true *)
   ```

#### Performance Benchmarks
Comprehensive benchmarking performed using OCaml's Benchmark library across different data sizes:
- Small lists (1,000 elements)
- Medium lists (5,000 elements)
- Large lists (10,000 elements)

#### Features
- Generic implementations (`'a list` support)
- Type-safe operations
- Functional programming approach
- Clear and consistent interface


### 📊 Sorting Algorithms (`ocaml_sorts/`)
A comprehensive collection of sorting algorithms implemented in OCaml, with performance benchmarking using both Core_bench and Bechamel libraries.

#### Implemented Algorithms
- **Bubble Sort**: Simple comparison-based sorting (O(n²))
- **Insertion Sort**: Builds sorted array one item at a time (O(n²))
- **Quick Sort**: Divide-and-conquer sorting algorithm (O(n log n))
- **Merge Sort**: Divide-and-conquer algorithm for integer lists (O(n log n))
- **Heap Sort**: Array-based heap sorting (O(n log n))
- **Timsort**: Hybrid sorting algorithm (O(n log n))

#### Performance Analysis
Benchmarked using two different libraries:
- **Core_bench**: Provides a simple interface for benchmarking functions
- **Bechamel**: Offers more detailed and customizable benchmarking capabilities: Time complexity, memory allocation, CPU cycles, cache behavior, etc.

#### Features
- Comprehensive benchmarking suite
- Type-safe sorting implementations
- Functional programming approach
- Performance comparison across different sorting algorithms

### 🌳 Tree Data Structures (`ocaml_trees/`)
A comprehensive collection of tree data structure implementations in OCaml, featuring various tree types optimized for different use cases.

#### Implemented Tree Types

1. **AVL Tree** (`avl_tree.ml`)
   - Self-balancing binary search tree
   - Maintains O(log n) height balance
   - Automatic rebalancing after insertions and deletions
   - Ideal for frequent lookups

2. **Binary Tree** (`binary_tree.ml`)
   - Basic binary tree implementation
   - Foundation for other tree structures
   - Supports standard tree operations
   - Useful for learning and simple hierarchical data

3. **Patricia Tree** (`patricia_tree.ml`)
   - Radix tree variant
   - Space-optimized for sparse data
   - Efficient prefix operations
   - Commonly used in network routing tables

4. **Red-Black Tree** (`red_black_tree.ml`)
   - Self-balancing binary search tree
   - Guaranteed O(log n) operations
   - Efficient deletion operations
   - Good for frequent insertions/deletions

5. **Trie Tree** (`trie_tree.ml`)
   - Prefix tree implementation
   - Efficient string operations
   - Word lookup and prefix matching
   - Useful for dictionary implementations

#### Features
- Type-safe implementations
- Comprehensive test coverage
- Well-documented interfaces
- Balance maintenance where applicable

### 🕸️ Graph Algorithms (`ocaml_graphs/`)
A comprehensive collection of graph data structures and algorithms in OCaml, supporting both directed and undirected graphs with optional edge weights.

1. **Undirected Graph** (`Undirect_graph`)
   - Basic undirected graph implementation
   - Edge representation as vertex pairs
   - Graph traversal algorithms (DFS, BFS)
   ```ocaml
   (* Creating and using undirected graph *)
   let g = Undirect_graph.create 5
   let () = Undirect_graph.add_edge g (0, 1)
   ```

2. **Weighted Graph** (`Weight_graph`)
   - Supports both directed and undirected edges
   - Edge weights for path calculations
   - Classic graph algorithms implementation
   ```ocaml
   (* Creating weighted graph *)
   let g = Weight_graph.create 5
   let edge = { src = 0; dest = 1; weight = 10 }
   ```

3. **Priority Queue** (Supporting Structure)
   - Optimized for graph algorithms
   - Essential for Dijkstra's algorithm
   - Efficient priority-based operations


### 🔐 Cryptographic Utilities (`ocaml_digestif_hash/`)
A comprehensive collection of cryptographic implementations using various hash algorithms and digital signature schemes.


1. **Digital Signatures**
   - **Common Interface** (`digital_signature_common.ml`)
     - Generic signature operations
     - Algorithm-agnostic design

   - **SHA3-256 Verifier** (`digital_signature_verifier_sha3_256.ml`)
     - Specific implementation using SHA3-256
     - String-based signature handling

2. **File Integrity**
   - **SHA256 Implementation** (`file_integrity_sha256.ml`)
     - File checksum generation
     - Integrity verification
     - Hash comparison utilities

3. **Password Storage**
   - **SHA256 Handler** (`password_storage_sha256.ml`)
     - Secure password hashing
     - Salt management
     - Verification routines

4. **Blockchain Protocol**
   - **RIPEMD160 Implementation** (`simple_blockchain_protocol_ripemd160.ml`)
     - Block hashing
     - Chain verification
     - RIPEMD160 hash algorithm

5. **Unique Identifiers**
   - **BLAKE2b Implementation** (`uids_blake2b.ml`)
     - Secure UUID generation
     - Cryptographic random numbers
     - BLAKE2b hash function

#### Supported Hash Algorithms
- SHA3-256
- SHA256
- RIPEMD160
- BLAKE2b

#### Security Features
- Cryptographic hash functions
- Digital signatures
- File integrity checking
- Secure password storage
- Blockchain primitives
- Unique identifier generation

#### Common Use Cases
- Document signing and verification
- File integrity validation
- Secure password management
- Blockchain development
- Unique ID generation

#### Implementation Notes
- Uses OCaml Digestif library
- String-based interfaces
- Cross-platform compatibility
- Modular design for algorithm switching


### 🌐 Network Programming
- TCP Client/Server Implementation (`ocaml_tcp_client_server/`)
  - Basic TCP communication
  - CLI interface for network operations

- GC-Aware TCP Server/Client (`ocaml_gc_tcp_server_client/`)
  - Memory-optimized implementation
  - Garbage collection considerations
  - Performance tuning examples

### 💻 Command Line Interface (`ocaml_cli_examples/`)
- Command-line argument parsing
- CLI application examples
- Arg module usage demonstrations

## 🎯 Goals
- Provide clean, well-documented OCaml implementations of common data structures and algorithms
- Demonstrate functional programming patterns and best practices
- Serve as a reference for OCaml developers
- Offer practical examples of OCaml's features in real-world applications


## 🎯 Future Plans

- Add more algorithm implementations
- Enhance documentation with more examples
- Improve performance benchmarking
- Add visualization tools for data structures

## 📝 License

This project is open-sourced under the MIT License - see the LICENSE file for details.

## 📞 Contact

For any questions or feedback, please contact me at [lykimq@gmail.com](mailto:lykimq@gmail.com).

