import Vapor

enum Route {
	case membersConnect
	case membersCallback
	case fansConnect
	case fansCallback
	
	case apiMembers
	case apiFans
	case apiUpdate
	case apiClean
	
	var path: String {
		switch self {
		case .membersConnect: return "members/connect"
		case .membersCallback: return "members/callback"
		case .fansConnect: return "fans/connect"
		case .fansCallback: return "fans/callback"
		case .apiMembers: return "api/members"
		case .apiFans: return "api/fans"
		case .apiUpdate: return "api/update"
		case .apiClean: return "api/clean"
		}
	}
}
