import FluentPostgreSQL
import Vapor

final class UserSummary: PostgreSQLModel {
    var id: Int?
	var firstName: String
	var lastName: String
	var isFan: Bool
	
	var runTotalActivities: Int
	var runTotalDistance: Double
	var runTotalMovingTime: Int
	var runAverageDistance: Double
	var runAverageMovingTime: Double
	
	var rideTotalActivities: Int
	var rideTotalDistance: Double
	var rideTotalMovingTime: Int
	var rideAverageDistance: Double
	var rideAverageMovingTime: Double
	
	var swimTotalActivities: Int
	var swimTotalDistance: Double
	var swimTotalMovingTime: Int
	var swimAverageDistance: Double
	var swimAverageMovingTime: Double

	init(id: Int? = nil, firstName: String, lastName: String, isFan: Bool, runTotalActivities: Int, runTotalDistance: Double, runTotalMovingTime: Int, runAverageDistance: Double, runAverageMovingTime: Double, rideTotalActivities: Int, rideTotalDistance: Double, rideTotalMovingTime: Int, rideAverageDistance: Double, rideAverageMovingTime: Double, swimTotalActivities: Int, swimTotalDistance: Double, swimTotalMovingTime: Int, swimAverageDistance: Double, swimAverageMovingTime: Double) {
        self.id = id
        self.firstName = firstName
		self.lastName = lastName
		self.isFan = isFan
		
        self.runTotalActivities = runTotalActivities
        self.runTotalDistance = runTotalDistance
		self.runTotalMovingTime = runTotalMovingTime
		self.runAverageDistance = runAverageDistance
		self.runAverageMovingTime = runAverageMovingTime
		
		self.rideTotalActivities = rideTotalActivities
        self.rideTotalDistance = rideTotalDistance
		self.rideTotalMovingTime = rideTotalMovingTime
		self.rideAverageDistance = rideAverageDistance
		self.rideAverageMovingTime = rideAverageMovingTime
		
		self.swimTotalActivities = swimTotalActivities
        self.swimTotalDistance = swimTotalDistance
		self.swimTotalMovingTime = swimTotalMovingTime
		self.swimAverageDistance = swimAverageDistance
		self.swimAverageMovingTime = swimAverageMovingTime
	}
}

extension UserSummary: Migration { }
extension UserSummary: Content { }
extension UserSummary: Parameter { }
