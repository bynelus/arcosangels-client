import Vapor

final class APIController {
	struct Constants {
		static let verifyToken = "DeKingsMacht12"
	}
	
	func membersRun(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, false)
			.filter(\.runTotalActivities, .greaterThan, 0)
			.sort(\.runTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}
	
	func membersRide(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, false)
			.filter(\.rideTotalActivities, .greaterThan, 0)
			.sort(\.rideTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}
	
	func membersSwim(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, false)
			.filter(\.swimTotalActivities, .greaterThan, 0)
			.sort(\.swimTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}

	func fansRun(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, true)
			.filter(\.runTotalActivities, .greaterThan, 0)
			.sort(\.runTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}
	
	func fansRide(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, true)
			.filter(\.rideTotalActivities, .greaterThan, 0)
			.sort(\.rideTotalDistance, .descending)
			.all()
			.map { $0.map { DetailedUserModelMapper.map($0) } }
	}
	
	func fansSwim(_ req: Request) throws -> Future<[DetailedUserModel]> {
		return UserSummary.query(on: req)
			.filter(\.isFan, .equal, true)
			.filter(\.swimTotalActivities, .greaterThan, 0)
			.sort(\.swimTotalDistance, .descending)
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
			let url = "https://www.strava.com/api/v3/athlete/activities?after=1609426800&before=1640991599&per_page=200"
			return try req.client().get(url, headers: ["Authorization": "Bearer " + content.access_token])
		}.flatMap(to: [StravaActivity].self) { response in
			return try response.content.decode([StravaActivity].self)
		}.flatMap(to: UserSummary.self) { activities in
			
			let mapToType: (String) -> (Int, Double, Int, Double, Double) = { type in
				let total = activities.filter { $0.type == type }
				let totalDistance = total.reduce(0.0) { $0 + $1.distance }
				let totalTime = total.reduce(0) { $0 + $1.moving_time }
				let averageDistance = total.isEmpty ? 0.0 : totalDistance / Double(total.count)
				let averageMovingTime = total.isEmpty ? 0.0 : Double(totalTime) / Double(total.count)
				return (total.count, totalDistance, totalTime, averageDistance, averageMovingTime)
			}
			
			let run = mapToType("Run")
			let ride = mapToType("Ride")
			let swim = mapToType("Swim")
			
			return UserSummary(id: user.id,
							   firstName: user.firstName,
							   lastName: user.lastName,
							   isFan: user.isFan,
							   runTotalActivities: run.0,
							   runTotalDistance: run.1,
							   runTotalMovingTime: run.2,
							   runAverageDistance: run.3,
							   runAverageMovingTime: run.4,
							   rideTotalActivities: ride.0,
							   rideTotalDistance: ride.1,
							   rideTotalMovingTime: ride.2,
							   rideAverageDistance: ride.3,
							   rideAverageMovingTime: ride.4,
							   swimTotalActivities: swim.0,
							   swimTotalDistance: swim.1,
							   swimTotalMovingTime: swim.2,
							   swimAverageDistance: swim.3,
							   swimAverageMovingTime: swim.4).create(orUpdate: true, on: req)
		}
	}
}
