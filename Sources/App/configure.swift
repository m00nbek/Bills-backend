import Vapor
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // mongodb
    if let key = Environment.get("DB_KEY") {
        try app.databases.use(.mongo(connectionString: key), as: .mongo)
    }
    
    // register routes
    try routes(app)
    
    
    app.migrations.add(CreateExpense())
    app.migrations.add(CreateExpenseNote())
}
