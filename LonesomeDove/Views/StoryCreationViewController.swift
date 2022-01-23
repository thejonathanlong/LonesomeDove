//
//  StoryCreationViewController.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import Combine
import PencilKit
import SwiftUIFoundation
import SwiftUI
import UIKit

// MARK: - DrawingViewControllerDisplayable
protocol StoryCreationViewControllerDisplayable {
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never> { get }
    func didUpdate(drawing: PKDrawing)
    func leadingButtons() -> [ButtonViewModel]
    func trailingButtons() -> [ButtonViewModel]
    var delegate: StoryCreationViewModelDelegate? { get set }
    var timerViewModel: TimerViewModel { get }
}

// MARK: - DrawingViewController
class StoryCreationViewController: UIViewController, PKCanvasViewDelegate, StoryCreationViewModelDelegate {
    // MARK: - Properties
    private let viewModel: StoryCreationViewControllerDisplayable
    private let drawingView = PKCanvasView()
    private let tools = PKToolPicker()
    private let hostedButtonsViewController: HostedViewController<ActionButtonsView<TimerViewModel>>
    private let buttonsContainer = UIView()
    private let buttonsVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: StoryCreationViewControllerDisplayable) {
        self.viewModel = viewModel

        self.hostedButtonsViewController = HostedViewController(contentView: ActionButtonsView(leadingModels: viewModel.leadingButtons(), trailingModels: viewModel.trailingButtons(), timerViewModel: viewModel.timerViewModel))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIView
extension StoryCreationViewController {
    override func loadView() {
        super.loadView()
        drawingView.delegate = self
        drawingView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(drawingView)
        view.addSubview(buttonsContainer)
        buttonsVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(buttonsVisualEffectView)
        hostedButtonsViewController.embed(in: self, with: buttonsContainer, shouldPinToParent: false)

        buttonsContainer.layer.cornerRadius = 12
        buttonsContainer.layer.masksToBounds = true

        NSLayoutConstraint.activate(buttonsVisualEffectView.pin(to: buttonsContainer))
        NSLayoutConstraint.activate(drawingViewConstraints())
        NSLayoutConstraint.activate(buttonContainerViewConstraints())
        NSLayoutConstraint.activate(buttonsViewConstraints())

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tools.addObserver(drawingView)
        tools.setVisible(true, forFirstResponder: drawingView)
        drawingView.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubscribers()
    }
}

// MARK: - Private
private extension StoryCreationViewController {
    func drawingViewConstraints() -> [NSLayoutConstraint] {
        [
            drawingView.topAnchor.constraint(equalTo: view.topAnchor),
            drawingView.widthAnchor.constraint(equalTo: view.widthAnchor),
            drawingView.heightAnchor.constraint(equalTo: view.heightAnchor),
            drawingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }

    func buttonContainerViewConstraints() -> [NSLayoutConstraint] {
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        guard let buttonsView = hostedButtonsViewController.view else { return [] }
        return [
//            buttonsContainer.topAnchor.constraint(equalTo: drawingView.bottomAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            buttonsContainer.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, constant: 12)

        ]
    }

    func buttonsViewConstraints() -> [NSLayoutConstraint] {
        guard let buttonsView = hostedButtonsViewController.view else { return [] }
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        return [
            buttonsView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0)
        ]
    }

    func addSubscribers() {
        viewModel
            .drawingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.drawing, on: drawingView)
            .store(in: &cancellables)
    }
}

// MARK: - PKCanvasViewDelegate
extension StoryCreationViewController {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.didUpdate(drawing: canvasView.drawing)
    }
}

// MARK: - StoryCreationViewModelDelegate
extension StoryCreationViewController {
    func currentImage() -> UIImage? {
        drawingView.snapshot()
    }
}
