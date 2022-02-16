//
//  Router.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import Foundation
import Media
import SwiftUIFoundation
import UIKit

typealias DismissViewControllerHandler = (() -> Void)?

enum Route {
    case alert(AlertViewModel, DismissViewControllerHandler)
    case confirmCancelAlert(ConfirmCancelViewModel)
    case dismissPresentedViewController(DismissViewControllerHandler)
    case loading
    case newStory(StoryCreationViewModel)
    case readStory(StoryCardViewModel)
    case showStickers([Sticker])
    case warning(Warning)
    
    enum Warning {
        case uniqueName
        case noPages
        
        var alertViewModel: AlertViewModel {
            switch self {
                case .uniqueName:
                    return AlertViewModel(title: "That Name is taken", message: "You have a story with that name. Can you think of another title?", actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])
                
                case .noPages:
                    return AlertViewModel(title: "No Pages",
                                          message: "You have not added any pages to your story. Try drawing on this page and pressing the record button to tell your story.",
                                          actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])
            }
        }
    }
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
                showAlert(viewModel: viewModel)

            case .dismissPresentedViewController(let completion):
                rootViewController?.presentedViewController?.dismiss(animated: true, completion: completion)

            case .alert(let viewModel, let completion):
                showAlert(viewModel: viewModel, completion: completion)

            case .loading:
                showQuippyLoader()

            case .readStory(let viewModel):
                Task {
                    try await read(story: viewModel)
                }
                
            case .showStickers(let stickers):
                show(stickers: stickers)
            
            case .warning(let warning):
                show(warning)
        }
    }
}

// MARK: - Private
private extension Router {
    func showDrawingViewController(for viewModel: StoryCreationViewModel, from presenter: UIViewController?) {
        guard let presenter = presenter else {
            print("Warning: Presenter was nil. That is probably why \(#function) did not work.")
            return
        }
        let drawingViewController = StoryCreationViewController(viewModel: viewModel)
        viewModel.delegate = drawingViewController
        drawingViewController.modalPresentationStyle = .fullScreen
        presenter.present(drawingViewController, animated: true, completion: nil)
    }

    func showAlert(viewModel: ConfirmCancelViewModel) {
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
    }

    func showAlert(viewModel: AlertViewModel, completion: (() -> Void)?) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        viewModel.actions.forEach {
            alert.addAction($0)
        }

        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        presentingViewController?.present(alert, animated: true, completion: completion)
    }

    func showQuippyLoader() {
        let viewModel = QuipsLoadingViewModel()
        let loadingView = LoadingView(viewModel: viewModel)
        let hostingController = HostedViewController(contentView: loadingView, backgroundView: nil, alignment: .fill(.zero))
        hostingController.modalPresentationStyle = .fullScreen
        rootViewController?.presentedViewController?.present(hostingController, animated: true) {
            viewModel.start()
        }
    }

    @MainActor func read(story: StoryCardViewModel) async throws {
        let viewModelFactory = PlayerViewModelFactory()
        let playerViewModel = try await viewModelFactory.playerViewModel(from: story)
        let playerView = PlayerView(viewModel: playerViewModel)
        let hostingController = HostedViewController(contentView: playerView, backgroundView: nil, alignment: .fill(.zero))
        hostingController.modalPresentationStyle = .fullScreen
        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        presentingViewController?.present(hostingController, animated: true, completion: {
            playerViewModel.togglePlayPause()
        })
    }
    
    func show(_ warning: Route.Warning) {
        showAlert(viewModel: warning.alertViewModel, completion: nil)
    }
    
    func show(stickers: [Sticker]) {
        let viewModel = StickersGridViewModel(stickerDisplayables: stickers)
        let background = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        let hostingController = HostedViewController(contentView: DrawingComponentsGridView(viewModel: viewModel), backgroundView: background, alignment: .fill(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)))
        hostingController.modalPresentationStyle = .formSheet
        
        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        presentingViewController?.present(hostingController, animated: true, completion: nil)
        
    }
}
