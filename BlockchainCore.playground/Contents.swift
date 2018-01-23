//: Playground - noun: a place where people can play

import Foundation

protocol SmartContract {
  func apply(to transaction: Transaction)
}

class SmartContractTransation: SmartContract {
  func apply(to transaction: Transaction) {
    var fee = 0.0
    switch transaction.type {
    case .domestic:
      fee = 0.02
    case .international:
      fee = 0.05
    }
    transaction.fee = transaction.amount * fee
    transaction.amount -= transaction.fee
  }
}

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

enum TransactionType: String, Codable { case domestic, international }

class Transaction: Codable {
  // PROPERTIES
  var from: String
  var to: String
  var amount: Double
  var fee: Double = 0.0
  var type: TransactionType
  
  // INITIALIZER
  init(from: String, to: String, amount: Double, type: TransactionType) {
    self.from = from
    self.to = to
    self.amount = amount
    self.type = type
  }
  
  // FUNCTIONS
  func asString() -> String {
    guard let transactionsData = try? JSONEncoder().encode(self),
      let transactionsJSONString = String(data: transactionsData, encoding: .utf8) else { return "" }
    return transactionsJSONString
  }
}

class Block: Codable {
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

class Blockchain: Codable {
  // PROPERTIES
  private (set) var blocks: [Block] = []
  private (set) var smartContracts: [SmartContractTransation] = [SmartContractTransation()]
  
  // INITIALIZER
  init(genesisBlock: Block) {
    addBlock(genesisBlock)
  }
  
  private enum CodingKeys : CodingKey { case blocks }

  // FUNCTIONS
  func addBlock(_ block: Block) {
    // Is genesis block?
    if blocks.isEmpty {
      block.previousHash = "0000000000000000"
      block.hash = HashGenerator.generateHash(for: block)
    }
    // Run smart contracts
    smartContracts.forEach { contract in
      block.transactions.forEach { transaction in
        contract.apply(to: transaction)
      }
    }
    // Add block
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

print("------------------------------\n -- ADD GENESIS BLOCK -- \n------------------------------")
let genesisBlock = Block()
let blockchain = Blockchain(genesisBlock: genesisBlock)

print("------------------------------\n -- ADD BLOCK w/ TRANSACTIONS -- \n------------------------------")
let transaction1 = Transaction(from: "x1", to: "x2", amount: 20, type: .domestic)
let transaction2 = Transaction(from: "x3", to: "x4", amount: 10, type: .international)
let block = blockchain.getNextBlock(transactions: [transaction1, transaction2])
blockchain.addBlock(block)
print("------------------------------\n -- END -- \n------------------------------")
print("Number of blocks: \(blockchain.blocks.count)")
print("------------------------------\n -- BLOCKCHAIN INFO -- \n------------------------------")
let data = try! JSONEncoder().encode(blockchain)
let blockchainInfo = String(data: data, encoding: .utf8)
print(blockchainInfo!)


