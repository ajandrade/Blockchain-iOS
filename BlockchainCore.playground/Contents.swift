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
  
  var key: String? {
    guard let transactionInfo = transactionsAsString() else { return nil }
    return String(index) + previousHash + String(nonce) + transactionInfo
  }
  
  func addTransaction(_ transaction: Transaction) {
    transactions.append(transaction)
  }
  
  private func transactionsAsString() -> String? {
    guard let transactionsData = try? JSONEncoder().encode(transactions),
      let transactionsJSONString = String(data: transactionsData, encoding: .utf8) else { return nil }
    return transactionsJSONString
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
