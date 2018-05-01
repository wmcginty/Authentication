import Foundation
import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    let authRouteController = AuthenticationRouteController()
    try authRouteController.boot(router: router)
    
    let userRouteController = UserRouteController()
    try userRouteController.boot(router: router)
}
