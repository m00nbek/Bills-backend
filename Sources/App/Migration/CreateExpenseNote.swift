//
//  CreateExpenseNote.swift
//  
//
//  Created by m00nbek Melikulov on 1/24/23.
//

import Fluent

struct CreateExpenseNote: AsyncMigration {
    // Prepares the database for storing Expense models.
    func prepare(on database: Database) async throws {
        try await database.schema(ExpenseNote.schema)
            .id()
            .field("message", .string)
            .field("created_at", .date)
            .field("expense_id", .uuid, .required, .references("expense", "id"))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(ExpenseNote.schema).delete()
    }
}
