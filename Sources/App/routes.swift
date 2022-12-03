import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Ohayo!"
    }
    
    app.get("feed") { req async throws in
        try await Expense.query(on: req.db).all()
    }
}
