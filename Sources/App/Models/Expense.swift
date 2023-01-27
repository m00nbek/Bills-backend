//
//  Expense.swift
//  
//
//  Created by m00nbek Melikulov on 12/2/22.
//

import Vapor
import Fluent

final class Expense: Model, Content {
    
    // empty initializer
    init() { }
    
    // Name of the table or collection.
    static let schema = "test-feed"

    // Unique identifier for this Expense.
    @ID(key: .id)
    var id: UUID?

    // title
    @Field(key: "title")
    var title: String
    
    // createdAt
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // cost
    @Field(key: "cost")
    var cost: Float
    
    // currency
    @Field(key: "currency")
    var currency: String
    
    // previous
    @OptionalParent(key: "previous")
    var previous: Expense?
    
    // next
    @OptionalParent(key: "next")
    var next: Expense?
    
    // notes
    @Children(for: \.$expense)
    var notes: [ExpenseNote]
    
    init(id: UUID? = nil, title: String, cost: Float, currency: String) {
        self.id = id
        self.title = title
        self.cost = cost
        self.currency = currency
    }
}
