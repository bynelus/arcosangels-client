import Vapor

struct StravaRefreshTokenRequest {
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
