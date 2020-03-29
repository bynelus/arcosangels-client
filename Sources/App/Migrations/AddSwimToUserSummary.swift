import Vapor
import FluentPostgreSQL

struct AddSwimToUserSummary: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
		return PostgreSQLDatabase.update(UserSummary.self, on: conn) { builder in
			builder.field(for: \.swimTotalActivities, type: .int, .default(.init(integerLiteral: 0)))
			builder.field(for: \.swimTotalDistance, type: .doublePrecision, .default(.init(floatLiteral: 0.0)))
			builder.field(for: \.swimTotalMovingTime, type: .int, .default(.init(integerLiteral: 0)))
			builder.field(for: \.swimAverageDistance, type: .doublePrecision, .default(.init(floatLiteral: 0.0)))
			builder.field(for: \.swimAverageMovingTime, type: .doublePrecision, .default(.init(floatLiteral: 0.0)))
        }
    }
	
	static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
		return PostgreSQLDatabase.update(UserSummary.self, on: conn) { builder in
            builder.deleteField(for: \.swimTotalActivities)
			builder.deleteField(for: \.swimTotalDistance)
			builder.deleteField(for: \.swimTotalMovingTime)
			builder.deleteField(for: \.swimAverageDistance)
			builder.deleteField(for: \.swimAverageMovingTime)
        }
	}
}
