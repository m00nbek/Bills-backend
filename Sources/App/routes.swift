import Vapor

func routes(_ app: Application) throws {
    
    // home page `/`
    app.get { req async in
        "Ohayo!"
    }
    
    // query all the feed items
    app.get("feed") { req async throws in
        let items = try await Expense.query(on: req.db).all()
        return ItemWrapper(items: items)
    }
   
    // create new feed item
    app.post("feed") { req -> EventLoopFuture<Expense> in
        let expense = try req.content.decode(Expense.self)
        
        // setting the timestamp
        expense.timestamp = Date().ISO8601Format()
        
        return expense.create(on: req.db).map { expense }
    }
}
