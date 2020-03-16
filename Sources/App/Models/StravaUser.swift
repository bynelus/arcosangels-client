import FluentPostgreSQL
import Vapor

final class StravaUser: PostgreSQLModel {
    var id: Int?
	var firstName: String
	var lastName: String
	var refreshToken: String

    init(id: Int? = nil, firstName: String, lastName: String, refreshToken: String) {
        self.id = id
        self.firstName = firstName
		self.lastName = lastName
        self.refreshToken = refreshToken
    }
}

extension StravaUser: Migration { }
extension StravaUser: Content { }
extension StravaUser: Parameter { }
