//
//  Router.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Foundation
import UIKit

enum Route {
    case newStory(DrawingViewControllerDisplayable)
}

protocol RouteController {
    var rootViewController: UIViewController? { get set }
    func route(to destination: Route)
}

class Router: RouteController {
    
    static let shared = Router()
    
    var rootViewController: UIViewController?
    
    
    func route(to destination: Route) {
        switch destination {
            
        case .newStory(let drawingViewControllerDisplayable):
            showDrawingViewController(for: drawingViewControllerDisplayable, from: rootViewController?.presentedViewController ?? rootViewController)
        }
    }
}

private extension Router {
    func showDrawingViewController(for viewModel: DrawingViewControllerDisplayable, from presenter: UIViewController?) {
        guard let presenter = presenter else {
            print("Warning: Presenter was nil. That is probably why \(#function) did not work.")
            return
        }
        let drawingViewController = DrawingViewController(viewModel: viewModel)
        presenter.present(drawingViewController, animated: true, completion: nil)
    }
}
