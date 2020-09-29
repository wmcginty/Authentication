import Foundation
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ app: Application) throws {
    
    let authRouteController = AuthenticationRouteController()
    try authRouteController.boot(routes: app)
    
    let userRouteController = UserRouteController()
    try userRouteController.boot(routes: app)
    
    let protectedRouteController = ProtectedRoutesController()
    try protectedRouteController.boot(routes: app)
}
