import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "Just a website."
    }
    
    // Status
    let stravaController = StravaController()
    router.get("connect", use: stravaController.connect)
	router.get("connectcallback", use: stravaController.connectCallback)
	router.get("update", use: stravaController.update)
	router.get("json", use: stravaController.json)
}
