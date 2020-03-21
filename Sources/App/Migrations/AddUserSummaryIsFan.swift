import Vapor
import FluentPostgreSQL

struct AddUserSummaryIsFan: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
		return PostgreSQLDatabase.update(UserSummary.self, on: conn) { builder in
			builder.field(for: \.isFan, type: .boolean, .default(.literal(.boolean(.false))))
        }
    }
	
	static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
		return PostgreSQLDatabase.update(UserSummary.self, on: conn) { builder in
            builder.deleteField(for: \.isFan)
        }
	}
}
