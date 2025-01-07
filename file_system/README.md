# OCaml File System Implementation

A flexible and efficient file system implementation in OCaml offering both simple balanced and AVL tree-based approaches for managing files and directories.

## Core Features

- **Dual Balancing Strategies**
  - Simple threshold-based balancing for smaller file systems
  - AVL tree-based balancing for larger file systems
- **Basic Operations**
  - Create, remove, and find files/directories
  - Directory traversal and manipulation
- **String Conversion Utilities**
  - Multiple encoding options (Base64, Hex, Escaped strings)
  - Human-readable format conversion

## System Architecture

### 1. Basic File System (`File_Directory`)
- Core file system operations
- List-based directory structure
- Foundation for both balancing implementations

### 2. Balancing Implementations

#### AVL Tree-Based (`File_System_Avl_Tree_Balance`)
- Self-balancing tree structure
- O(log n) performance guarantee
- Ideal for:
  - Large directories
  - Frequent modifications
  - Performance-critical systems

#### Simple Balance (`File_System_Simple_Balance`)
- Threshold-based balancing
- Lower overhead implementation
- Best for:
  - Small to medium directories
  - Systems prioritizing simplicity
  - Less frequent modifications

### 3. String Utilities (`String_Conversion`)
- String escape handling
- Multiple encoding options:
  - Hexadecimal
  - Base64
  - Human-readable formatting

## Performance Characteristics

| Implementation | Best Use Case | Performance | Memory Usage |
|----------------|---------------|-------------|--------------|
| AVL Tree | Large directories | O(log n) guaranteed | Higher |
| Simple Balance | Small-medium directories | O(log n) average, O(n) worst | Lower |

## Contributing Guidelines

1. Documentation
   - All functions must include documentation
   - Keep interface files (.mli) up to date

2. Testing
   - Add unit tests for new features
   - Ensure existing tests pass

3. Code Standards
   - Follow OCaml coding conventions
   - Maintain type safety
   - Use meaningful variable names