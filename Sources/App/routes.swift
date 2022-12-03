import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Ohayo!"
    }
    
    app.get("feed") { req async throws in
        try await Expense.query(on: req.db).all()
    }
    
    app.post("feed") { req -> EventLoopFuture<Expense> in
        let expense = try req.content.decode(Expense.self)
        
        // setting the timestamp
        expense.timestamp = Date().ISO8601Format()
        
        return expense.create(on: req.db)
            .map { expense }
    }
}
