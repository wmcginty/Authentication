import Vapor
import FluentSQLite

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    // Configure Fluents SQL provider
    try services.register(FluentSQLiteProvider())
    
    // Configure our database
    var databaseConfig = DatabaseConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)auth.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)
    
    // Configure our model migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self, database: .sqlite)
    migrationConfig.add(model: AccessToken.self, database: .sqlite)
    migrationConfig.add(model: RefreshToken.self, database: .sqlite)
    services.register(migrationConfig)
}
