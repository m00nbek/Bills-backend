//
//  CreateExpense.swift
//  
//
//  Created by m00nbek Melikulov on 12/3/22.
//

import Fluent

struct CreateExpense: AsyncMigration {
    // Prepares the database for storing Expense models.
    func prepare(on database: Database) async throws {
        try await database.schema(Expense.schema)
            .id()
            .field("title", .string)
            .field("created_at", .date)
            .field("cost", .float)
            .field("currency", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema(Expense.schema).delete()
    }
}
