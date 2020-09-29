import Vapor
import FluentSQLiteDriver

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // Register routes to the router
    try routes(app)
    
    // Configure our database
    app.databases.use(.sqlite(.file("auth.db.sqlite")), as: .sqlite)
    
    // Configure our model migrations
    app.migrations.add([User.Migration(), AccessToken.Migration(), RefreshToken.Migration()], to: .sqlite)
    
    if app.environment == .development {
        _ = app.autoMigrate()
    }
}
