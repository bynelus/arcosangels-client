import Vapor

enum Route {
	case membersConnect
	case membersCallback
	case fansConnect
	case fansCallback
	
	case apiMembersRun
	case apiMembersRide
	case apiMembersSwim
	case apiFansRun
	case apiFansRide
	case apiFansSwim
	case apiUpdate
	case apiClean
	case apiPush
	
	var path: String {
		switch self {
		case .membersConnect: return "members/connect"
		case .membersCallback: return "members/callback"
		case .fansConnect: return "fans/connect"
		case .fansCallback: return "fans/callback"
		case .apiMembersRun: return "api/members/run"
		case .apiMembersRide: return "api/members/ride"
		case .apiMembersSwim: return "api/members/swim"
		case .apiFansRun: return "api/fans/run"
		case .apiFansRide: return "api/fans/ride"
		case .apiFansSwim: return "api/fans/swim"
		case .apiUpdate: return "api/update"
		case .apiClean: return "api/clean"
		case .apiPush: return "api/push"
		}
	}
}
