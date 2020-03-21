import Vapor

final class StravaController {
	struct Constants {
		static let clientId = "44626"
		static let activityScope = "activity:read_all"
		static let readScope = "read"
		static let scope = [activityScope, readScope].joined(separator: ",")
	}
	
	func connect(_ req: Request) throws -> Response {
		return try startConnect(req, isFan: false)
	}
	
	func connectCallback(_ req: Request) throws -> Future<Response> {
		return try processCallback(req, isFan: false)
	}
	
	func fanConnect(_ req: Request) throws -> Response {
		return try startConnect(req, isFan: true)
	}
	
	func fanConnectCallback(_ req: Request) throws -> Future<Response> {
		return try processCallback(req, isFan: true)
	}
	
	private func startConnect(_ req: Request, isFan: Bool) throws -> Response {
		let path = isFan ? Route.fansCallback.path : Route.membersCallback.path
		let callbackUrl = appUrl + path
		return req.redirect(to: "https://www.strava.com/oauth/authorize?client_id=\(Constants.clientId)&response_type=code&redirect_uri=\(callbackUrl)&approval_prompt=force&scope=\(Constants.scope)")
	}
	
	private func processCallback(_ req: Request, isFan: Bool) throws -> Future<Response> {
		guard let code = req.query[String.self, at: "code"],
				let scope = req.query[String.self, at: "scope"],
				scope.contains(Constants.activityScope)
				else { throw Abort(.badRequest) }
		
			let request = try req.client().post("https://www.strava.com/oauth/token", beforeSend: { req in
				let payload = StravaAccessTokenRequest.Payload(code: code)
				try req.content.encode(payload, as: .json)
			})
			
			return request.flatMap { response in
				return try response.content.decode(StravaAccessTokenRequest.Result.self)
			}.flatMap(to: StravaUser.self) { content in
				return StravaUser(id: content.athlete.id, firstName: content.athlete.firstname, lastName: content.athlete.lastname, refreshToken: content.refresh_token, isFan: isFan).create(orUpdate: true, on: req)
			}.map { user in
				return req.redirect(to: "/" + Route.apiUpdate.path)
			}
	}
}
