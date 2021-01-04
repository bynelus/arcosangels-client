import FluentPostgreSQL
import Vapor

var appUrl = "http://localhost:8080/"

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a database
    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL"), env.isRelease {
      databaseConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS)!
    } else {
      databaseConfig = .init(hostname: "127.0.0.1", port: 5432, username: "nielskoole", database: "arcos", password: nil, transport: .cleartext)
    }
    let postgres = PostgreSQLDatabase(config: databaseConfig)

    // Register the configured database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)
	
	if env.isRelease {
		appUrl = "https://arcos-angels-strava-client.herokuapp.com/"
	}

	// Configure migrations
    var migrations = MigrationConfig()
	
	// Create initial models
//    migrations.add(model: StravaUser.self, database: .psql)
//	migrations.add(model: UserSummary.self, database: .psql)
    
    StravaUser.defaultDatabase = .psql
    UserSummary.defaultDatabase = .psql
	
	// Migrations
	migrations.add(migration: AddStravaUserIsFan.self, database: .psql)
	migrations.add(migration: AddUserSummaryIsFan.self, database: .psql)
	migrations.add(migration: AddSwimToUserSummary.self, database: .psql)
    services.register(migrations)
}
