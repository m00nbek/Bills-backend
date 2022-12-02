//
//  Expense.swift
//  
//
//  Created by m00nbek Melikulov on 12/2/22.
//

import Fluent

final class Expense: Model {
    
    // empty initializer
    init() { }
    
    // Name of the table or collection.
    static let schema = "feed"

    // Unique identifier for this Expense.
    @ID(key: .id)
    var id: UUID?

    // title
    @Field(key: "title")
    var title: String
    
    // timestamp
    @Field(key: "timestamp")
    var timestamp: Date
    
    // cost
    @Field(key: "cost")
    var cost: Float
    
    // currency
    @Field(key: "currency")
    var currency: String
    
    init(id: UUID? = nil, title: String, timestamp: Date, cost: Float, currency: String) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.cost = cost
        self.currency = currency
    }
}
