//: Playground - noun: a place where people can play

import Foundation

struct Transaction {
  var from: String
  var to: String
  var amount: Double
}

class Block {
  var index: Int = 0
  var previousHash: String = ""
  var hash: String!
  var nonce: Int = 0
  
  private (set) var transactions: [Transaction] = []
  
  var key: String {
    return ""
  }
  
  func addTransaction(_ transaction: Transaction) {
    transactions.append(transaction)
  }
}

class Blockchain {
  private (set) var blocks: [Block] = []
  
  init(genesisBlock: Block) {
    addBlock(genesisBlock)
  }
  
  func addBlock(_ block: Block) {
    if blocks.isEmpty {
      block.previousHash = "0000000000000000"
    }
    blocks.append(block)
  }
}


