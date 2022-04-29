//
//  Router.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import Foundation
import Media
import SwiftUIFoundation
import UIKit
import os

typealias DismissViewControllerHandler = (() -> Void)?

enum Route {
    case addStickerToStory(StickerDisplayable)
    case alert(AlertViewModel, DismissViewControllerHandler)
    case confirmCancelAlert(ConfirmCancelViewModel)
    case dismissPresentedViewController(DismissViewControllerHandler)
    case loading
    case newStory(StoryCreationViewModel)
    case previewStory(URL)
    case readStory(StoryCardViewModel)
    case shareStory(URL?)
    case showStickerDrawer([Sticker])
    case warning(Warning)
    case toggleStoryCreationMenu

    enum Warning {
        case uniqueName
        case noPages
        case badStickerData
        case generic

        var alertViewModel: AlertViewModel {
            switch self {
                case .uniqueName:
                    return AlertViewModel(title: "That Name Is Taken", message: "You have a story with that name. Can you think of another title?", actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])

                case .noPages:
                    return AlertViewModel(title: "There Are No Pages",
                                          message: "You have not added any pages to your story. Try drawing on this page and pressing the record button to tell your story.",
                                          actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])

                case .badStickerData:
                    return AlertViewModel(title: "The Sticker Has a Problem",
                                          message: "Something is not quite right with this sticker. It might be damaged. Please try again.",
                                          actions: [UIAlertAction(title: "Ok", style: .default, handler: nil)])

                case .generic:
                    return AlertViewModel(title: "Something Is Wrong",
                                          message: "Well something went wrong. Please try again.",
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

    private var logger = Logger(subsystem: "com.LonesomeDove.Router", category: "LonesomeDove")
    
    private var currentRouteStack: [Route] = []

    func route(to destination: Route) {
        switch destination {

            case .newStory(let drawingViewControllerDisplayable):
                showDrawingViewController(for: drawingViewControllerDisplayable, from: rootViewController?.presentedViewController ?? rootViewController)

            case .confirmCancelAlert(let viewModel):
                showAlert(viewModel: viewModel)

            case .dismissPresentedViewController(let completion):
                // Pop twice because we are always pushing
                _ = currentRouteStack.popLast()
                rootViewController?.presentedViewController?.dismiss(animated: true, completion: completion)

            case .alert(let viewModel, let completion):
                showAlert(viewModel: viewModel, completion: completion)

            case .loading:
                showQuippyLoader()

            case .readStory(let viewModel):
                Task {
                    try await read(story: viewModel)
                }

            case .showStickerDrawer(let stickers):
                show(stickerDrawer: stickers)

            case .warning(let warning):
                show(warning)

            case .addStickerToStory(let sticker):
                addStickerToStory(sticker)
            
            case .shareStory(let URL):
                showShareSheet(for: URL)
            
            case .previewStory(let url):
                Task {
                    await preview(storyURL: url)
                }
            
            case .toggleStoryCreationMenu:
                showStoryCreationMenu()
        }
        
        currentRouteStack.append(destination)
    }
}

// MARK: - Private
private extension Router {
    func showDrawingViewController(for viewModel: StoryCreationViewModel, from presenter: UIViewController?) {
        guard let presenter = presenter else {
            logger.log("Warning: Presenter was nil. That is probably why \(#function) did not work.")
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

    func show(stickerDrawer: [Sticker]) {
        let viewModel = StickersGridViewModel(stickerDisplayables: stickerDrawer)
        viewModel.store = AppLifeCycleManager.shared.store
        let background = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        let hostingController = HostedViewController(contentView: StickerGridView(viewModel: viewModel), backgroundView: background, alignment: .fill(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)))
        hostingController.modalPresentationStyle = .formSheet

        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        presentingViewController?.present(hostingController, animated: true, completion: nil)
    }

    func addStickerToStory(_ sticker: StickerDisplayable) {
        let storyCreationViewController = rootViewController?.presentedViewController as? StoryCreationViewController
        do {
            try storyCreationViewController?.add(sticker: sticker)
        } catch let stickerError as StickerState.Error {
            route(to: .warning(stickerError.warning))
        } catch let e {
            logger.log("Caught an error that is being handled as a generic error. \(e.localizedDescription)")
            route(to: .warning(.generic))
        }
    }
    
    func showShareSheet(for url: URL?) {
        let activityViewController = UIActivityViewController(activityItems: [url].compactMap { $0 }, applicationActivities: nil)
        let navigationController = UINavigationController(rootViewController: activityViewController)
        
        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        navigationController.popoverPresentationController?.sourceView = presentingViewController?.view
        
        presentingViewController?.popoverPresentationController?.sourceView = presentingViewController?.view
        presentingViewController?.present(navigationController, animated: true)
    }
    
    @MainActor func preview(storyURL: URL) async {
        let viewModelFactory = PlayerViewModelFactory()
        let playerViewModel = await viewModelFactory.playerViewModel(from: storyURL)
        let playerView = PlayerView(viewModel: playerViewModel)
        let hostingController = HostedViewController(contentView: playerView, backgroundView: nil, alignment: .fill(.zero))
        hostingController.modalPresentationStyle = .fullScreen
        let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
        presentingViewController?.present(hostingController, animated: true, completion: {
            playerViewModel.togglePlayPause()
        })
    }
    
    func showStoryCreationMenu() {
        guard let storyCreationViewController = rootViewController?.presentedViewController as? StoryCreationViewController else { return }
        storyCreationViewController.toggleMenu()
    }
}
