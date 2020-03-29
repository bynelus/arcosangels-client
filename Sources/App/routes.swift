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
	router.get(Route.apiMembersRun.path, use: apiController.membersRun)
	router.get(Route.apiMembersRide.path, use: apiController.membersRide)
	router.get(Route.apiFansRun.path, use: apiController.fansRun)
	router.get(Route.apiFansRide.path, use: apiController.fansRide)
	router.get(Route.apiUpdate.path, use: apiController.update)
	router.get(Route.apiClean.path, use: apiController.clean)
	router.get(Route.apiPush.path, use: apiController.validatePush)
	router.post(Route.apiPush.path, use: apiController.push)
}
