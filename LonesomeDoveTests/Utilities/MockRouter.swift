//
//  MockRouter.swift
//  LonesomeDoveTests
//
//  Created on 4/5/22.
//

@testable import LonesomeDove
import Foundation
import UIKit

class MockRouter: RouteController {
    var rootViewController: UIViewController?
    
    var routingHandler: (Route) -> Void
    
    init(rootViewController: UIViewController? = nil,
         routingHandler: @escaping (Route) -> Void) {
        self.rootViewController = rootViewController
        self.routingHandler = routingHandler
    }
    
    func route(to destination: Route) {
        routingHandler(destination)
    }
}
