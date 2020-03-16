import Vapor

struct StravaActivity: Content {
	let name: String
	let distance: Double
	let moving_time: Int
	let type: String
	let commute: Bool
}

