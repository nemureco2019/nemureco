import Leaf
import Vapor
import FluentPostgreSQL
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    
     // Configure  database--------------------------------------------------------------------------
     var databases = DatabasesConfig()
     let databaseConfig: PostgreSQLDatabaseConfig
     if let url = Environment.get("postgresql://ue57e7283343b1895ae8ce33f4cbdf8c:p97a5ea20a1e04c2d81080f4f470ec82@database.v2.vapor.cloud:30001/d7d4aafb175c8471") {
     guard let urlConfig = PostgreSQLDatabaseConfig(url: url) else {
     fatalError("Failed to create PostgresConfig")
     }
     databaseConfig = urlConfig
     } else {
     let databaseName: String
     let databasePort: Int
     if (env == .testing) {
     databaseName = "vapor-test"
     if let testPort = Environment.get("DATABASE_PORT") {
     databasePort = Int(testPort) ?? 30001
     } else {
     databasePort = 30001
     }
     }
     else {
     databaseName = Environment.get("DATABASE_DB") ?? "d7d4aafb175c8471"
     databasePort =  30001
     }
     
     let hostname = Environment.get("DATABASE_HOSTNAME") ?? "database.v2.vapor.cloud"
     let username = Environment.get("DATABASE_USER") ?? "ue57e7283343b1895ae8ce33f4cbdf8c"
     let password = Environment.get("DATABASE_PASSWORD") ?? "p97a5ea20a1e04c2d81080f4f470ec82"
     databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: username, database: databaseName, password: password)
     }
     let database = PostgreSQLDatabase(config: databaseConfig)
     databases.add(database: database, as: .psql)
     services.register(databases)
 /*
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    //PostGreSQLの設定　hostname:localhost/username:postgre:database:nidomi
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "hondayuushun",database:"api")
    let postGreSQL = PostgreSQLDatabase(config:databaseConfig)
    //PostgreSQLをデータベースに追加
    databases.add(database:postGreSQL,as:.psql)
    services.register(databases)
 */
    //Leafの追加２
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model:User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: SleepData.self, database: .psql)
    migrations.add(model: SubUser.self, database: .psql)
    migrations.add(model: Emfit.self, database: .psql)
  
    services.register(migrations)
}
