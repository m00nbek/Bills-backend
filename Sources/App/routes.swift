import Vapor

func routes(_ app: Application) throws {
    
    // home page `/`
    app.get("bills") { req async in
        "Ohayo!"
    }
    
    // query all the feed items
    app.get("bills", "test-feed") { req async throws in
        let items = try await Expense.query(on: req.db).all()
        return ItemWrapper(items: items)
    }
   
    // create new feed item
    app.post("bills", "test-feed") { req -> EventLoopFuture<Expense> in
        let expense = try req.content.decode(Expense.self)
        
        // setting the timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
        expense.timestamp = timestamp
        
        return expense.create(on: req.db).map { expense }
    }
}
