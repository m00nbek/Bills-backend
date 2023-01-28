import Vapor
import FluentKit

func routes(_ app: Application) throws {
    
    var routePrefix: PathComponent {
        let routePrefix = Environment.get("ROUTE_PREFIX") ?? ""
        return PathComponent(stringLiteral: routePrefix)
    }
    
    // MARK: - Group `v1`
    let v1 = app.grouped(routePrefix, "v1")
    
    // home page `/`
    v1.get("") { req async in
        "Ohayo!"
    }
    
    // MARK: - Group `feed`
    let feed = v1.grouped("feed")
    
    // query all the feed items
    feed.get("all") { req async throws in
        let items = try await Expense.query(on: req.db).all()
        return ItemWrapper(items: items)
    }
    
    // query paginated feed
    feed.get("") { req in
        let paginatedRequest = try req.query.decode(PaginatedRequest.self)
        
        guard let limit = paginatedRequest.limit,
              let afterId = paginatedRequest.afterId else {
            // first page
            let items = try await Expense.query(on: req.db).limit(10).all()
            return ItemWrapper(items: items)
        }
        
        let allItems = try await Expense.query(on: req.db).all()
        var offset = 0
       
        // get the index of the afterId item
        for (index, item) in allItems.enumerated() {
            if item.id == afterId {
                offset = index
            }
        }
        
        let query = try await Expense.query(on: req.db)
            // adding +1 here to get the next item
            .offset(offset+1)
            .limit(limit)
            .all()
        
        return ItemWrapper(items: query)
    }
    
    // create new feed item
    feed.post("") { req in
        let expenseRequest = try req.content.decode(ExpenseRequest.self)
        
        guard let lastExpense = try await Expense.query(on: req.db).all().last else {
            return try await createFirstExpense(from: req, on: req.db)
        }
        
        let newExpense = Expense(id: UUID(), title: expenseRequest.title, cost: expenseRequest.cost, currency: expenseRequest.currency)

        lastExpense.$next.id = newExpense.id
        newExpense.$previous.id = lastExpense.id
        newExpense.$next.id = nil
        
        try await lastExpense.update(on: req.db)
        try await newExpense.create(on: req.db)
        
        return newExpense
    }
    
    // MARK: - Group `expense`
    let expense = v1.grouped("expense")
    
    // get expense with id
    expense.get(":id") { req async throws in
        let expense = try await getExpense(params: req.parameters, db: req.db)
        return expense
    }
    
    // get notes for expense with expense id
    expense.get(":id", "notes") { req async throws in
        let expense = try await getExpense(params: req.parameters, db: req.db)
        let notes = try await expense.$notes.get(on: req.db)
        return ItemWrapper(items: notes)
    }
    
    // post a note for expense with expense id
    expense.post(":id") { req in
        let noteMessage = try req.content.decode(Message.self)
        
        let expense = try await getExpense(params: req.parameters, db: req.db)
        let expenseNote = ExpenseNote(expenseID: expense.id!, message: noteMessage.message)
        
        try await expense.$notes.create(expenseNote, on: req.db)
        
        return expenseNote
    }
    
    // MARK: - Helpers
    func createFirstExpense(from req: Request, on db: Database) async throws -> Expense {
        let expenseRequest = try req.content.decode(ExpenseRequest.self)
        
        let newExpense = Expense(title: expenseRequest.title, cost: expenseRequest.cost, currency: expenseRequest.currency)
        newExpense.$previous.id = nil
        newExpense.$next.id = nil
        
        try await newExpense.create(on: db)
        
        return newExpense
    }
    
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
