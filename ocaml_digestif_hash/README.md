# `digestif` hash algorithms

| Algorithm    | Bit Length | Speed      | Security     | Best Use Case                                          |
|--------------|------------|------------|--------------|-------------------------------------------------------|
| **MD5**      | 128 bits   | Fast       | Weak         | Checksums, non-cryptographic integrity checks          |
| **SHA1**     | 160 bits   | Moderate   | Weak         | Legacy systems, compatibility purposes                 |
| **SHA224**   | 224 bits   | Moderate   | Secure       | Shorter hashes for limited space, moderate security    |
| **SHA256**   | 256 bits   | Moderate   | Strong       | General-purpose cryptography, blockchain, digital sig. |
| **SHA384**   | 384 bits   | Slower     | Very Strong  | Enhanced security for sensitive data                   |
| **SHA512**   | 512 bits   | Slower     | Very Strong  | High-security applications, cryptographic protocols    |
| **BLAKE2B**  | 256-512 bits | Very Fast | Strong       | Password hashing, general-purpose cryptographic use    |
| **BLAKE2S**  | 128-256 bits | Very Fast | Strong       | Lightweight systems, fast hashing on 32-bit platforms  |
| **SHA3_224** | 224 bits   | Moderate   | Very Strong  | Modern cryptography with smaller hash size             |
| **SHA3_256** | 256 bits   | Moderate   | Very Strong  | General cryptographic hashing, digital signatures      |
| **SHA3_384** | 384 bits   | Slower     | Very Strong  | High-security cryptography, digital signatures         |
| **SHA3_512** | 512 bits   | Slower     | Very Strong  | High-security, long-lived cryptographic applications   |
| **Keccak_224** | 224 bits | Moderate   | Strong       | Similar to SHA3-224 but for specific cryptographic use |
| **Keccak_256** | 256 bits | Moderate   | Strong       | Pre-standard SHA3-256, blockchain, cryptography        |
| **Keccak_384** | 384 bits | Slower     | Strong       | Pre-standard SHA3-384, secure protocols                |
| **Keccak_512** | 512 bits | Slower     | Strong       | Pre-standard SHA3-512, secure communication protocols  |
| **RIPEMD160** | 160 bits  | Moderate   | Moderate     | Bitcoin, blockchain, cryptographic systems             |

Summary:
- MD5 and SHA1: Fast but insecure, used in non-cryptographic contexts or for
  legacy compatibility.
- SHA-2 family (SHA224, SHA256, SHA384, SHA512): strong security, widely used
  for modern cryptographic applications.
- BLAKE2 (BLAKE2B, BLAKE2S): Optimized for speed, especially useful in password
  hashing or for fast cryptographic needs.
- SHA-3 family (SHA3_224, SHA3_256, SHA3_384, SHA3_512): High-security
  algorithms suitable for morden cryptographic needs.
- Keccak: Pre-standard version of SHA-3, useful for specific applications
  needing backward compatibility.
- RIPEMD160: Common in cryptocurrency (e.g., Bitcoin) but less widely used
  outside of blockchain applications.


## Implementation Examples

### 1. BLAKE2B for Unique Identifiers
The `uids_blake2b.mli` implementation provides a robust unique identifier system using BLAKE2B:
- Fast and cryptographically secure identifier generation
- Support for verification and shortened UIDs
- Ability to combine multiple UIDs
- Ideal for distributed systems requiring unique, verifiable identifiers

### 2. RIPEMD160 for Blockchain
The `simple_blockchain_protocol_ripemd160.mli` implements a basic blockchain structure:
- Uses RIPEMD160 for block hashing (common in cryptocurrency systems)
- Includes block verification and chain integrity checking
- Supports basic blockchain operations (genesis block creation, adding blocks)
- Suitable for educational purposes or simple blockchain implementations

### 3. SHA256 for File Integrity
The `file_integrity_sha256.mli` provides file integrity verification:
- Computes and verifies SHA256 hashes of files
- Supports hash storage and retrieval
- Useful for file verification and integrity checking
- Common in software distribution and backup verification

### 4. SHA3-256 for Digital Signatures
The `digital_signature_verifier_sha3_256.mli` implements:
- Ed25519 signature scheme with SHA3-256 hashing
- Complete key pair generation and management
- Document signing and verification
- Suitable for secure document authentication

### 5. Password Storage with SHA256
The `password_storage_sha256.mli` provides secure password handling:
- Salted password hashing using SHA256
- Secure password verification
- Follows modern password storage best practices

### Common Digital Signature Interface
The `digital_signature_common.mli` provides:
- Generic interface for digital signatures
- Pluggable hash function support
- Ed25519 key pair management
- Flexible signature creation and verification

## Best Practices and Usage Guidelines

### Choosing the Right Algorithm
1. **For Password Storage**:
   - Prefer dedicated password hashing functions (e.g., Argon2, bcrypt)
   - SHA256 implementation provided is for educational purposes

2. **For Digital Signatures**:
   - Use SHA3-256 or BLAKE2B for modern applications
   - Consider RIPEMD160 for blockchain compatibility

3. **For File Integrity**:
   - SHA256 provides a good balance of security and performance
   - BLAKE2B is a faster alternative for large files

4. **For Unique Identifiers**:
   - BLAKE2B offers excellent performance and security
   - Suitable for high-throughput systems

### Security Considerations
- All implementations include proper error handling
- Salt is used where appropriate (password storage)
- Cryptographic operations use secure random number generation
- Input validation is implemented across all modules

### Performance Notes
- BLAKE2B provides the best performance for general use
- SHA256 and SHA3-256 offer good all-around performance
- RIPEMD160 is maintained for blockchain compatibility
- Consider hardware acceleration support when choosing algorithms
