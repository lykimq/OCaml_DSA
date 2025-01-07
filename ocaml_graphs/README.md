# OCaml Graph Implementations

This project provides two graph implementations in OCaml: an undirected graph (`Undirect_graph`) and a weighted graph (`Weight_graph`) with various graph algorithms.

## Implementations

### 1. Undirected Graph (`Undirect_graph`)

A basic graph implementation supporting unweighted, undirected edges.

#### Features
- Graph creation with a specified number of vertices
- Adding undirected edges between vertices
- Querying vertex neighbors
- Graph traversal algorithms:
  - Depth-First Search (DFS)
  - Breadth-First Search (BFS)

### 2. Weighted Graph (`Weight_graph`)

A more advanced implementation supporting weighted edges and pathfinding algorithms.

#### Features
- Support for both directed and undirected weighted edges
- Priority Queue implementation for efficient algorithms
- Graph algorithms:
  - Dijkstra's Shortest Path
  - Kruskal's Minimum Spanning Tree (MST)

#### Key Components

##### Priority Queue
- Efficient implementation for managing vertices by priority
- Operations:
  - `create`: Create new empty queue
  - `add`: Add element with priority
  - `take`: Remove and return highest priority element
  - `is_empty`: Check if queue is empty

##### Graph Operations
- Edge management (add edges with weights)
- Neighbor queries with weights
- Vertex enumeration

## Testing

The project includes comprehensive test suites for both implementations.

### Undirected Graph Tests
- Tests basic graph operations
- Verifies correct DFS traversal order
- Validates BFS level-order traversal
- Tests edge cases and error conditions

### Weighted Graph Tests
- Priority Queue operations
  - Adding and taking elements
  - Empty queue checks
- Dijkstra's Algorithm
  - Tests on both directed and undirected graphs
  - Verifies correct shortest path distances
- Kruskal's Algorithm
  - Validates MST edge selection
  - Tests on various graph configurations

## Implementation Details

### Dijkstra's Algorithm
- Finds shortest paths from a source vertex to all other vertices
- Uses priority queue for efficient vertex selection
- Time complexity: O((V + E) log V)

### Kruskal's Algorithm
- Finds minimum spanning tree in undirected weighted graphs
- Uses Union-Find data structure to detect cycles
- Time complexity: O(E log E)