import Vapor

public func routes(_ app: Application) throws {
    
    let authRouteController = AuthenticationRouteController()
    try authRouteController.boot(routes: app)
    
    let userRouteController = UserRouteController()
    try userRouteController.boot(routes: app)
    
    let socialUserRouteController = SocialUserRouteController()
    try socialUserRouteController.boot(routes: app)
    
    let protectedRouteController = ProtectedRoutesController()
    try protectedRouteController.boot(routes: app)
}
