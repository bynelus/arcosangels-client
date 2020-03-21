import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "Just a website."
    }
    
    // Members
    let stravaController = StravaController()
	router.get(Route.membersConnect.path, use: stravaController.connect)
	router.get(Route.membersCallback.path, use: stravaController.connectCallback)
	router.get(Route.fansConnect.path, use: stravaController.fanConnect)
	router.get(Route.fansCallback.path, use: stravaController.fanConnectCallback)
	
	// API
	let apiController = APIController()
	router.get(Route.apiMembers.path, use: apiController.members)
	router.get(Route.apiFans.path, use: apiController.fans)
	router.get(Route.apiUpdate.path, use: apiController.update)
	router.get(Route.apiClean.path, use: apiController.clean)
}
