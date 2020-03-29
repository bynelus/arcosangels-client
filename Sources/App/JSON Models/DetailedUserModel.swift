import Vapor

struct DetailedUserModel: Content {
	let name: String
	
	let totalRuns: String
	let averageRunDistance: String
	let averageRunMinutePerKM: String
	let totalRunDistance: String
	
	let totalRides: String
	let averageRideDistance: String
	let averageRideSpeed: String
	let totalRideDistance: String
	
	let totalSwims: String
	let averageSwimDistance: String
	let averageSwimSpeed: String
	let totalSwimDistance: String
}
