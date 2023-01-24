//
//  ExpenseNote.swift
//  
//
//  Created by m00nbek Melikulov on 1/24/23.
//

import Vapor
import Fluent

final class ExpenseNote: Model, Content {
    
    init() { }
    
    static let schema = "expense"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "message")
    var message: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Parent(key: "expense_id")
    var expense: Expense
    
    init(id: UUID? = nil, expenseID: Expense.IDValue, message: String) {
        self.id = id
        self.$expense.id = expenseID
        self.message = message
    }
}
