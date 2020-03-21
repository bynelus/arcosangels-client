import FluentPostgreSQL
import Vapor

final class StravaUser: PostgreSQLModel {
    var id: Int?
	var firstName: String
	var lastName: String
	var refreshToken: String
	var isFan: Bool

	init(id: Int? = nil, firstName: String, lastName: String, refreshToken: String, isFan: Bool) {
        self.id = id
        self.firstName = firstName
		self.lastName = lastName
        self.refreshToken = refreshToken
		self.isFan = isFan
    }
}

extension StravaUser: Migration { }
extension StravaUser: Content { }
extension StravaUser: Parameter { }
