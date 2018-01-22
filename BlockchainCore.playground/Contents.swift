//: Playground - noun: a place where people can play

import Foundation

struct Transaction: Codable {
  // PROPERTIES
  var from: String
  var to: String
  var amount: Double
}

class Block {
  // PROPERTIES
  var index: Int = 0
  var previousHash: String = ""
  var hash: String!
  var nonce: Int = 0
  
  private (set) var transactions: [Transaction] = []
  
  var key: String {
    return String(index) + previousHash + String(nonce) + transactionsAsString()
  }
  
  // FUNCTIONS
  func addTransaction(_ transaction: Transaction) {
    transactions.append(transaction)
  }
  
  // HELPER FUNCTIONS
  private func transactionsAsString() -> String {
    guard let transactionsData = try? JSONEncoder().encode(transactions),
      let transactionsJSONString = String(data: transactionsData, encoding: .utf8) else { return "" }
    return transactionsJSONString
  }
}

class Blockchain {
  // PROPERTIES
  private (set) var blocks: [Block] = []
  
  // INITIALIZER
  init(genesisBlock: Block) {
    addBlock(genesisBlock)
  }
  
  // FUNCTIONS
  func addBlock(_ block: Block) {
    if blocks.isEmpty {
      block.previousHash = "0000000000000000"
      block.hash = generateHash(for: block)
    }
    blocks.append(block)
  }
  
  func getNextBlock(transactions: [Transaction]) -> Block {
    let block = Block()
    transactions.forEach(block.addTransaction)
    let previousBlock = getPreviousBlock()
    block.index = blocks.count
    block.previousHash = previousBlock.hash
    block.hash = generateHash(for: block)
    return block
  }
  
  func getPreviousBlock() -> Block {
    return blocks.last ?? Block()
  }
  
  // HELPER FUNCTIONS
  private func generateHash(for block: Block) -> String {
    var hash = block.key.sha1()
    // last block @ 22/01/2018:
    // 0000000000000000000ab398448c2713f3c8dd65a490857ef6e885128f812c85
    while(!hash.hasPrefix("00")) {  // For simplicity (and performance :)), I'll keep two 0s instead of 19
      block.nonce += 1
      hash = block.key.sha1()
      print(hash)
    }
    return hash
  }
}

// TESTING

print("------------------------------\n -- GENESIS BLOCK -- \n------------------------------")
let genesisBlock = Block()
let blockchain = Blockchain(genesisBlock: genesisBlock)
let transaction = Transaction(from: "x1", to: "x2", amount: 20)
print("------------------------------\n -- BLOCK w/ TRANSACTION -- \n------------------------------")
let block = blockchain.getNextBlock(transactions: [transaction])
blockchain.addBlock(block)
print("------------------------------\n -- END -- \n------------------------------")
print("Number of blocks: \(blockchain.blocks.count)")
