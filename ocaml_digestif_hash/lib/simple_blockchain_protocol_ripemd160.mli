(* Define a type for a block in a blockchain *)
type block = {
  index : int; (* The position of the block in the chain *)
  previous_hash : string; (* The hash of the previous block *)
  data : string; (* Data stored in the block, could be any information *)
  timestamp : float; (* Timestamp of block creation *)
  hash : string; (* Hash of the current block *)
}

module Blockchain : sig
  (* Calculate the hash of a block using its components
     @param index The block's position in the chain
     @param previous_hash Hash of the previous block
     @param data The data to be stored in the block
     @param timestamp The block creation time
     @return A RIPEMD160 hash string of the block's contents *)
  val calculate_hash : int -> string -> string -> float -> string

  (* Create the first block in the blockchain (genesis block)
     @return A new block with index 0 and arbitrary previous hash *)
  val create_genesis_block : unit -> block

  (* Add a new block to the chain
     @param previous_block The last block in the current chain
     @param data The data to be stored in the new block
     @return A new block with incremented index and calculated hash *)
  val add_block : block -> string -> block

  (* Verify the integrity of the blockchain
     @param chain The list of blocks to verify, ordered from oldest to newest
     @return true if the chain is valid (all hashes match), false otherwise *)
  val verify_chain : block list -> bool
end
