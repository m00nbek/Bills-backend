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
        let id = try getId(from: req)
        let expense = try await getExpense(for: id, from: req.db)
        return expense
    }
    
    // get notes for expense with expense id
    app.get("v1", "expense", ":id", "notes") { req async throws in
        let id = try getId(from: req)
        let expense = try await getExpense(for: id, from: req.db)
        let notes = try await expense.$notes.get(on: req.db)
        return notes
    }
    
    // MARK: - Helpers
    func getExpense(for id: UUID, from db: Database) async throws -> Expense {
        // on `expense` not found, throw `notFound`
        guard let expense = try await Expense.find(id, on: db) else {
            throw Abort(.notFound)
        }
        
        return expense
    }
    
    func getId(from req: Request) throws -> UUID {
        // on invalid `id`, throw `badRequest`
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return id
    }
}
