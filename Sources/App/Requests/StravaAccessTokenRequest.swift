import Vapor
 
struct StravaAccessTokenRequest {
	struct Payload: Content {
		let client_id = "44626"
		let client_secret = "8e317109af109e8b542d902c88579a2274d5cf94"
		let grant_type = "authorization_code"
		let code: String
	}
	
	struct Result: Content {
		let refresh_token: String
		let athlete: StravaAthlete
	}
}
