import Vapor
import FluentKit

func routes(_ app: Application) throws {
    
    // home page `/`
    app.get("") { req async in
        "Ohayo!"
    }
    
    // query all the feed items
    app.get("v1", "feed") { req async throws in
        let items = try await Expense.query(on: req.db).all()
        return ItemWrapper(items: items)
    }
    
    // create new feed item
    app.post("v1", "feed") { req -> EventLoopFuture<Expense> in
        let expense = try req.content.decode(Expense.self)
        
        // setting the timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
        expense.timestamp = timestamp
        
        return expense.create(on: req.db).map { expense }
    }
    
    // get expense with id
    app.get("v1", "expense", ":id") { req async throws in
        let expense = try await getExpense(params: req.parameters, db: req.db)
        return expense
    }
    
    // get notes for expense with expense id
    app.get("v1", "expense", ":id", "notes") { req async throws in
        let expense = try await getExpense(params: req.parameters, db: req.db)
        let notes = try await expense.$notes.get(on: req.db)
        return notes
    }
    
    // post a note for expense with expense id
    app.post("v1", "expense", ":id") { req in
        let noteMessage = try req.content.decode(Message.self)
        
        let expense = try await getExpense(params: req.parameters, db: req.db)
        let expenseNote = ExpenseNote(expenseID: expense.id!, message: noteMessage.message)
        
        try await expense.$notes.create(expenseNote, on: req.db)
        
        return expenseNote
    }
    
    // MARK: - Helpers
    func getExpense(params: Parameters, db: Database) async throws -> Expense {
        let id = try getID(from: params)
        
        let expense: Expense = try await get(id: id, from: db)
        
        return expense
    }
    
    func get<Item: Model>(id: Item.IDValue, from db: Database) async throws -> Item {
        // on `Item` not found, throw `notFound`
        guard let item = try await Item.find(id, on: db) else {
            throw Abort(.notFound)
        }
        
        return item
    }
    
    func getID(from param: Parameters) throws -> UUID {
        // on invalid `id`, throw `badRequest`
        guard let id = param.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return id
    }
}
