//
//  Router.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Foundation
import UIKit

enum Route {
    case newStory(StoryCreationViewControllerDisplayable)
    case confirmCancelAlert(ConfirmCancelViewModel)
    case dismissPresentedViewController
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
        
        case .confirmCancelAlert(let viewModel):
        	let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: viewModel.dismissActionTitle, style: .cancel, handler: { [weak alert] _ in
                viewModel.dismiss(viewController: alert)
        	}))
            alert.addAction(UIAlertAction(title: viewModel.deleteActionTitle, style: .destructive, handler: { [weak alert] _ in
                viewModel.handleDelete(viewController: alert) { [weak self] in
                    self?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            }))
            rootViewController?.presentedViewController?.present(alert, animated: true, completion: nil)
        
        case .dismissPresentedViewController:
            rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        
        
    }
}

private extension Router {
    func showDrawingViewController(for viewModel: StoryCreationViewControllerDisplayable, from presenter: UIViewController?) {
        guard let presenter = presenter else {
            print("Warning: Presenter was nil. That is probably why \(#function) did not work.")
            return
        }
        var viewModel = viewModel
        let drawingViewController = StoryCreationViewController(viewModel: viewModel)
        viewModel.delegate = drawingViewController
        drawingViewController.modalPresentationStyle = .fullScreen
        presenter.present(drawingViewController, animated: true, completion: nil)
    }
}
