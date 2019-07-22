import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let webSightController = WebsightController()
    let userController = UserController()
    let sleepDataController = SleepDataController()
    
    try router.register(collection:webSightController)
    try router.register(collection:userController)
    try router.register(collection:sleepDataController)
}
