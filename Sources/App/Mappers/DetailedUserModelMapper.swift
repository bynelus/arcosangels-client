import Vapor

final class DetailedUserModelMapper {
	static func map(_ model: UserSummary) -> DetailedUserModel {
		let name = mapName(firstName: model.firstName, lastName: model.lastName)
		
		let totalRuns = "\(model.runTotalActivities)"
		let averageRunDistance = (model.runAverageDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		let averageRunMinutePerKM = mapAverageMinutePerKM(averageMovingTime: model.runAverageMovingTime, averageDistance: model.runAverageDistance)
		let totalRunDistance = (model.runTotalDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		
		let totalRides = "\(model.rideTotalActivities)"
		let averageRideDistance = (model.rideAverageDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		let averageRideSpeed = mapAverageKMPerHour(averageMovingTime: model.rideAverageMovingTime, averageDistance: model.rideAverageDistance)
		let totalRideDistance = (model.rideTotalDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		
		let totalSwims = "\(model.swimTotalActivities)"
		let averageSwimDistance = (model.swimAverageDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		let averageSwimSpeed = mapAverageKMPerHour(averageMovingTime: model.swimAverageMovingTime, averageDistance: model.swimAverageDistance)
		let totalSwimDistance = (model.swimTotalDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		
		return DetailedUserModel(name: name,
								 totalRuns: totalRuns,
								 averageRunDistance: averageRunDistance,
								 averageRunMinutePerKM: averageRunMinutePerKM,
								 totalRunDistance: totalRunDistance,
								 totalRides: totalRides,
								 averageRideDistance: averageRideDistance,
								 averageRideSpeed: averageRideSpeed,
								 totalRideDistance: totalRideDistance,
								 totalSwims: totalSwims,
								 averageSwimDistance: averageSwimDistance,
								 averageSwimSpeed: averageSwimSpeed,
								 totalSwimDistance: totalSwimDistance)
	}
	
	private static func mapName(firstName: String, lastName: String) -> String {
		switch lastName {
		case "Poot", "Koole": return lastName
		default: break
		}
		
		switch firstName {
		case "Luuk": return "Haas"
		default: break
		}
		
		return firstName
	}
	
	private static func mapAverageMinutePerKM(averageMovingTime: Double, averageDistance: Double) -> String {
		guard averageMovingTime > 0 && averageDistance > 0 else { return "00:00" }
		let secondsPerKM = averageMovingTime / (averageDistance / 1000)
		let minutes = Int(floor(secondsPerKM / 60))
		let seconds = Int(round(secondsPerKM.truncatingRemainder(dividingBy: 60)))
		return String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
	}
	
	private static func mapAverageKMPerHour(averageMovingTime: Double, averageDistance: Double) -> String {
		guard averageMovingTime > 0 && averageDistance > 0 else { return "00:00" }
		let speed = averageDistance / averageMovingTime * 3600 / 1000
		return speed.round(with: 2).replacingOccurrences(of: ".", with: ",")
	}
}
