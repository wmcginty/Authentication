import Vapor
import FluentPostgresDriver

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    
    // Register routes to the router
    try routes(app)
    
    // Configure our database
    app.databases.use(Environment.postgresConfiguration(), as: .psql)
    
    // Configure our model migrations
    app.migrations.add([User.Migration(), AccessToken.Migration(), RefreshToken.Migration()], to: .psql)
    
    if app.environment == .development {
        _ = app.autoMigrate()
    }
}

fileprivate extension Environment {
    
    static func postgresConfiguration() -> DatabaseConfigurationFactory {
        return .postgres(configuration: .init(hostname: "localhost", port: 5432, username: "postgres", password: "", database: "auth", tls: .disable), encodingContext: .default, decodingContext: .default)
    }
}
