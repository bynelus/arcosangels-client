import Vapor

final class APIController {
	struct Constants {
		static let verifyToken = "DeKingsMacht12"
	}
	
	func members(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, false)
			.sort(\.runTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}

	func fans(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, true)
			.sort(\.runTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}
	
	func update(_ req: Request) throws -> Future<HTTPStatus> {
		let users = StravaUser.query(on: req).all()
		
		return users.flatMap(to: [UserSummary].self) { [weak self] list in
			guard let strongSelf = self else { throw Abort(.badRequest) }
			let mapped = try list.map { try strongSelf.createRefreshRequest(req: req, user: $0) }
			return mapped.flatten(on: req)
		}.flatMap(to: Response.self) { userSummaries in
			return try req.client().post("https://api.netlify.com/build_hooks/5e726fd5f5621a89310045c7")
		}.transform(to: .ok)
	}
	
	func clean(_ req: Request) throws -> Future<HTTPStatus> {
		let deleteAll: EventLoopFuture<[Void]> = UserSummary.query(on: req).all().flatMap { list in
			let flatten = list.map { $0.delete(on: req) }
			return flatten.flatten(on: req)
		}
		
		return deleteAll.transform(to: .ok)
	}

	func validatePush(_ req: Request) throws -> StravaPushRequest.Payload {
		guard let challenge = req.query[String.self, at: "hub.challenge"],
			let verifyToken = req.query[String.self, at: "hub.verify_token"],
			verifyToken == Constants.verifyToken
			else { throw Abort(.badRequest) }
		
		return StravaPushRequest.Payload(challenge: challenge)
	}
	
	func push(_ req: Request) throws -> HTTPStatus {
		_ = try req.client().get(appUrl + Route.apiUpdate.path)
		return .ok
	}
}

extension APIController {
	func createRefreshRequest(req: Request, user: StravaUser) throws -> EventLoopFuture<UserSummary> {
		return try req.client().post("https://www.strava.com/oauth/token", beforeSend: { req in
			let payload = StravaRefreshTokenRequest.Payload(refresh_token: user.refreshToken)
			try req.content.encode(payload, as: .json)
		}).flatMap(to: StravaRefreshTokenRequest.Result.self) { response in
			return try response.content.decode(StravaRefreshTokenRequest.Result.self)
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
							   isFan: user.isFan,
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
