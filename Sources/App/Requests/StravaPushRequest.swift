import Vapor

struct StravaPushRequest {
	struct Payload: Content {
		private enum CodingKeys : String, CodingKey {
			case challenge = "hub.challenge"
		}
		
		let challenge: String
	}
}
