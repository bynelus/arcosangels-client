import Vapor

final class DetailedUserModelMapper {
	static func map(_ model: UserSummary) -> DetailedUserModel {
		let name = mapName(firstName: model.firstName, lastName: model.lastName)
		
		guard model.runTotalActivities > 0 else {
			return DetailedUserModel(name: name, hasData: true, totalRuns: "0", averageRunDistance: "0", averageRunMinutePerKM: "00:00", totalRunDistance: "")
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
		let minutesPerKM = (averageMovingTime / 60) / (averageDistance / 1000)
		let onlyMinutes = floor(minutesPerKM)
		let leftOverSeconds = 60 / (minutesPerKM.remainder(dividingBy: onlyMinutes) * 100)
		let minutes = String(format: "%02d", Int(onlyMinutes))
		let seconds = String(format: "%02d", Int(leftOverSeconds.rounded()))
		return minutes + ":" + seconds
	}
}
