import Vapor

final class DetailedUserModelMapper {
	static func map(_ model: UserSummary) -> DetailedUserModel {
		let name = mapName(firstName: model.firstName, lastName: model.lastName)
		
		guard model.runTotalActivities > 0 else {
			return DetailedUserModel(name: name, hasData: false, totalRuns: "0", averageRunDistance: "0", averageRunMinutePerKM: "00:00", totalRunDistance: "0")
		}
		
		let totalRuns = "\(model.runTotalActivities)"
		let averageRunDistance = (model.runAverageDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		let averageRunMinutePerKM = mapAverageMinutePerKM(averageMovingTime: model.runAverageMovingTime, averageDistance: model.runAverageDistance)
		let totalDistance = (model.runTotalDistance / 1000).round(with: 2).replacingOccurrences(of: ".", with: ",")
		return DetailedUserModel(name: name, hasData: true, totalRuns: totalRuns, averageRunDistance: averageRunDistance, averageRunMinutePerKM: averageRunMinutePerKM, totalRunDistance: totalDistance)
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
		let secondsPerKM = averageMovingTime / (averageDistance / 1000)
		let minutes = Int(floor(secondsPerKM / 60))
		let seconds = Int(round(secondsPerKM.truncatingRemainder(dividingBy: 60)))
		return String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
	}
}
