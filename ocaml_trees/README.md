# OCaml Tree Data Structures

This repository contains various tree data structure implementations in OCaml, providing efficient solutions for different use cases.

## Implementations

### 1. AVL Tree
A self-balancing binary search tree where the heights of two child subtrees of any node differ by at most one.

**Key Features:**
- Automatic height balancing
- O(log n) time complexity for insert, delete, and search operations
- Supports generic types with custom comparison functions
- Includes rotations (left, right, left-right, right-left) for maintaining balance

### 2. Trie Tree
A tree-like data structure optimized for string operations and prefix-based searches.

**Key Features:**
- Efficient string storage and retrieval
- Fast prefix-based operations
- Supports:
  - Word insertion and deletion
  - Exact string matching
  - Prefix-based word search
  - Word counting with prefix
  - Complete word list retrieval

### 3. Patricia Tree
A space-efficient variant of a trie (radix tree) that compresses paths by merging nodes with single children.

**Key Features:**
- Memory-efficient string storage
- Optimized for sparse datasets
- Supports:
  - String insertion and deletion
  - String search
  - Conversion to list of stored strings

### 4. Red-Black Tree
A self-balancing binary search tree that maintains balance using node coloring.

**Key Features:**
- Color-based balancing (Red/Black nodes)
- O(log n) time complexity for basic operations
- Supports:
  - Value insertion and deletion
  - Value search
  - Pretty printing (for integer trees)

### 5. Binary Tree
A basic binary tree implementation with standard traversal operations.

**Key Features:**
- Simple and intuitive implementation
- Supports:
  - Value insertion
  - Value search
  - Multiple traversal methods:
    - Inorder
    - Preorder
    - Postorder
  - Tree visualization (for integer trees)

## Testing

The implementation includes comprehensive test suites using the Alcotest framework. Tests cover:
- Basic operations (insert, delete, search)
- Edge cases
- Tree-specific functionality
- Balance maintenance (for balanced trees)