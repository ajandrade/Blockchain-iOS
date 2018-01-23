//: Playground - noun: a place where people can play

import Foundation

struct HashGenerator {
  static func generateHash(for block: Block) -> String {
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

struct Transaction: Codable {
  // PROPERTIES
  var from: String
  var to: String
  var amount: Double
  
  // FUNCTIONS
  func asString() -> String {
    guard let transactionsData = try? JSONEncoder().encode(self),
      let transactionsJSONString = String(data: transactionsData, encoding: .utf8) else { return "" }
    return transactionsJSONString
  }
}

class Block {
  // PROPERTIES
  var index: Int = 0
  var previousHash: String = ""
  var hash: String!
  var nonce: Int = 0
  
  private (set) var transactions: [Transaction] = []
  
  var key: String {
    let transactionsInfo = transactions.reduce("") { $0 + $1.asString() }
    return String(index) + previousHash + String(nonce) + transactionsInfo
  }
  
  // FUNCTIONS
  func addTransaction(_ transaction: Transaction) {
    transactions.append(transaction)
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
      block.hash = HashGenerator.generateHash(for: block)
    }
    blocks.append(block)
  }
  
  func getNextBlock(transactions: [Transaction]) -> Block {
    let block = Block()
    transactions.forEach(block.addTransaction)
    guard let previousBlock = getPreviousBlock() else {
      fatalError("Genesis block is missing!")
    }
    block.index = blocks.count
    block.previousHash = previousBlock.hash
    block.hash = HashGenerator.generateHash(for: block)
    return block
  }
  
  func getPreviousBlock() -> Block? {
    return blocks.last
  }
}

// TESTING

print("------------------------------\n -- GENESIS BLOCK -- \n------------------------------")
let genesisBlock = Block()
let blockchain = Blockchain(genesisBlock: genesisBlock)

let transaction1 = Transaction(from: "x1", to: "x2", amount: 20)
let transaction2 = Transaction(from: "x3", to: "x4", amount: 14)

print("------------------------------\n -- BLOCK w/ TRANSACTION -- \n------------------------------")
let block = blockchain.getNextBlock(transactions: [transaction1, transaction2])
blockchain.addBlock(block)
print("------------------------------\n -- END -- \n------------------------------")
print("Number of blocks: \(blockchain.blocks.count)")

