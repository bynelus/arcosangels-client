import Vapor

struct AccessToken {
	struct Payload: Content {
		let client_id = "44626"
		let client_secret = "8e317109af109e8b542d902c88579a2274d5cf94"
		let grant_type = "authorization_code"
		let code: String
	}
	
	struct Result: Content {
		let refresh_token: String
		let athlete: StravaAthlete
	}
}

struct RefreshToken {
	struct Payload: Content {
		let client_id = "44626"
		let client_secret = "8e317109af109e8b542d902c88579a2274d5cf94"
		let grant_type = "refresh_token"
		let refresh_token: String
	}
	
	struct Result: Content {
		let access_token: String
	}
}


final class StravaController {
	func connect(_ req: Request) throws -> Response {
		let callbackUrl = appUrl + "connectcallback"
		return req.redirect(to: "https://www.strava.com/oauth/authorize?client_id=44626&response_type=code&redirect_uri=\(callbackUrl)&approval_prompt=force&scope=read,activity:read_all")
	}
	
	func connectCallback(_ req: Request) throws -> Future<Response> {
		guard let code = req.query[String.self, at: "code"],
			let scope = req.query[String.self, at: "scope"],
			scope.contains("activity:read_all")
			else { throw Abort(.badRequest) }
	
		let request = try req.client().post("https://www.strava.com/oauth/token", beforeSend: { req in
			let payload = AccessToken.Payload(code: code)
			try req.content.encode(payload, as: .json)
		})
		
		return request.flatMap { response in
			return try response.content.decode(AccessToken.Result.self)
		}.flatMap(to: StravaUser.self) { content in
			return StravaUser(id: content.athlete.id, firstName: content.athlete.firstname, lastName: content.athlete.lastname, refreshToken: content.refresh_token).create(orUpdate: true, on: req)
		}.map { user in
			return req.redirect(to: "/update")
		}
	}
	
	func update(_ req: Request) throws -> Future<HTTPStatus> {
		let users = StravaUser.query(on: req).all()
		
		return users.flatMap(to: [UserSummary].self) { list in
			let mapped = try list.map { try self.createRefreshRequest(req: req, user: $0) }
			return mapped.flatten(on: req)
		}.transform(to: .ok)
	}
	
	func clean(_ req: Request) throws -> Future<HTTPStatus> {
		let deleteAll: EventLoopFuture<[Void]> = UserSummary.query(on: req).all().flatMap { list in
			let flatten = list.map { $0.delete(on: req) }
			return flatten.flatten(on: req)
		}
		
		return deleteAll.transform(to: .ok)
	}
	
	func json(_ req: Request) throws -> Future<[UserSummary]> {
		return UserSummary.query(on: req).sort(\.runTotalDistance, .descending).all()
	}
}

extension StravaController {
	func createRefreshRequest(req: Request, user: StravaUser) throws -> EventLoopFuture<UserSummary> {
		return try req.client().post("https://www.strava.com/oauth/token", beforeSend: { req in
			let payload = RefreshToken.Payload(refresh_token: user.refreshToken)
			try req.content.encode(payload, as: .json)
		}).flatMap(to: RefreshToken.Result.self) { response in
			return try response.content.decode(RefreshToken.Result.self)
		}.flatMap(to: Response.self) { content in
			let url = "https://www.strava.com/api/v3/athlete/activities?after=1577836800&before=1609459200&per_page=200"
			return try req.client().get(url, headers: ["Authorization": "Bearer " + content.access_token])
		}.flatMap(to: [StravaActivity].self) { response in
			return try response.content.decode([StravaActivity].self)
		}.flatMap(to: UserSummary.self) { activities in
			
			let running = activities.filter { $0.type == "Run" }
			let runningDistance = running.reduce(0.0) { $0 + $1.distance }
			let runningTime = running.reduce(0) { $0 + $1.moving_time }
			let runningDistanceAverage = running.isEmpty ? 0.0 : runningDistance / Double(running.count)
			let runningMovingTimeAverage = running.isEmpty ? 0.0 : Double(runningTime) / Double(running.count)
			
			let ride = activities.filter { $0.type == "Ride" }
			let rideDistance = ride.reduce(0.0) { $0 + $1.distance }
			let rideTime = ride.reduce(0) { $0 + $1.moving_time }
			let rideDistanceAverage = ride.isEmpty ? 0.0 : rideDistance / Double(ride.count)
			let rideMovingTimeAverage = ride.isEmpty ? 0.0 : Double(rideTime) / Double(ride.count)
			
			return UserSummary(id: user.id,
							   firstName: user.firstName,
							   lastName: user.lastName,
							   runTotalActivities: running.count,
							   runTotalDistance: runningDistance,
							   runTotalMovingTime: runningTime,
							   runAverageDistance: runningDistanceAverage,
							   runAverageMovingTime: runningMovingTimeAverage,
							   rideTotalActivities: ride.count,
							   rideTotalDistance: rideDistance,
							   rideTotalMovingTime: rideTime,
							   rideAverageDistance: rideDistanceAverage,
							   rideAverageMovingTime: rideMovingTimeAverage).create(orUpdate: true, on: req)
		}
	}
}
