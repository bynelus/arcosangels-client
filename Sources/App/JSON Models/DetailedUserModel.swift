import Vapor

struct DetailedUserModel: Content {
	let name: String
	let hasData: Bool
	let totalRuns: String
	let averageRunDistance: String
	let averageRunMinutePerKM: String
	let totalRunDistance: String
}
