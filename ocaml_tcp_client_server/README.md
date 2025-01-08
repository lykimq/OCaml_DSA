# OCaml TCP Client-Server Implementation

A robust, secure TCP client-server implementation in OCaml using Lwt for asynchronous I/O operations. This implementation features digital signatures, message integrity verification, and a flexible message type system.

## Features

- **Asynchronous Communication**: Built with Lwt for efficient concurrent operations
- **Secure Communication**:
  - Message integrity verification using Blake2b hashing
  - Digital signatures using Ed25519
  - Encrypted communication support
- **Flexible Message System**:
  - Multiple message types (Request, Response, Critical, Info, Warning, Debug, Error)
  - Structured message format with timestamps and verification data
- **Robust Error Handling**:
  - Graceful connection termination
  - Comprehensive error reporting
  - Safe socket cleanup
- **Command Line Interface**:
  - Both client and server CLI support
  - Configurable IP and port settings
  - Verbose logging option

## Usage

### Starting the Server

```
./tcp_server_cli start [-ip IP_ADDRESS] [-port PORT_NUMBER] [-v]
```

### Starting the Client

```
./tcp_client_cli <command> [-ip IP_ADDRESS] [-port PORT_NUMBER] [-v]
```


Commands:
- `start`: Connect to server
- `send <message_type> <message>`: Send a message
- `stop`: Disconnect from server

Message Types:
- Request
- Critical
- Info
- Warning
- Debug
- Error

## Security Features

- **Message Integrity**: Each message includes a Blake2b hash for integrity verification
- **Authentication**: Ed25519 digital signatures for message authenticity
- **Secure Socket Handling**: Proper socket cleanup and shutdown procedures
- **Error Recovery**: Robust error handling for network issues and invalid states

## API Documentation

### TCP Server

The server module (`TCP_Server`) provides:
- Connection management for multiple clients (max_clients limit)
- Secure message handling with digital signatures
- Graceful shutdown capabilities

### TCP Client

The client module (`TCP_Client`) offers:
- Connection establishment
- Message sending and receiving
- Clean disconnection handling

### Message System

The message module provides:
- Message type definitions
- Serialization/deserialization
- Cryptographic operations (hashing, signing, verification)