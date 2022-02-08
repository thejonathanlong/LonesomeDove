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
protocol StoryCreationViewControllerDisplayable: ObservableObject {
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never> { get }
    func didUpdate(drawing: PKDrawing)
    func leadingButtons() -> [ButtonViewModel]
    func trailingButtons() -> [ButtonViewModel]
    var delegate: StoryCreationViewModelDelegate? { get set }
    var timerViewModel: TimerViewModel { get }
    var storyNameViewModel: TextFieldViewModel { get set }
}

// MARK: - DrawingViewController
class StoryCreationViewController: UIViewController, PKCanvasViewDelegate, StoryCreationViewModelDelegate {
    // MARK: - Properties
    private let viewModel: StoryCreationViewModel
    
    private let drawingView = PKCanvasView()
    
    private let tools = PKToolPicker()
    
    private let hostedButtonsViewController: HostedViewController<AnyView>
    
    private let buttonsContainer = UIView()
    
    private let closedImage = UIImage(systemName: "arrow.right.circle.fill")!
    
    private lazy var closedImageView = UIImageView(image: closedImage)
    
    private let buttonsVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    
    private var helpOverlayView: HelpOverlayView?
    
    private var keyboardObserver = KeyboardObserver()
    
    private lazy var buttonsContainerBottomConstraint: NSLayoutConstraint? = {
        buttonsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
    }()

    private var cancellables = Set<AnyCancellable>()

    private var isShowingButtons = true

    lazy var imageSizing = CGSize(width: closedImage.size.width * 3, height: closedImage.size.height * 3)

    private var openTapGestureRecognizer: UITapGestureRecognizer?

    private lazy var buttonContainerViewOpenedConstraints: [NSLayoutConstraint] = {
        guard let buttonsView = hostedButtonsViewController.view,
              let buttonsContainerBottomConstraint = buttonsContainerBottomConstraint
        else { return [] }
        
        return [
            buttonsContainerBottomConstraint,
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            buttonsContainer.heightAnchor.constraint(equalTo: buttonsView.heightAnchor, constant: 12)
        ]
    }()

    private lazy var buttonsContainerViewClosedConstraints: [NSLayoutConstraint] = {
        return [
            buttonsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            buttonsContainer.heightAnchor.constraint(equalToConstant: imageSizing.height),
            buttonsContainer.widthAnchor.constraint(equalToConstant: imageSizing.width),
            closedImageView.centerXAnchor.constraint(equalTo: buttonsContainer.centerXAnchor),
            closedImageView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor)
        ]
    }()

    // MARK: - Init
    init(viewModel: StoryCreationViewModel) {
        self.viewModel = viewModel
        self.hostedButtonsViewController = HostedViewController(contentView: AnyView(StoryCreationControlsView<StoryCreationViewModel>().environmentObject(viewModel)))
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

        disableTranslatesAutoresizingMasksIntoConstraionts()

        addSubViews()

        closedImageView.alpha = 0.0
        closedImageView.isHidden = true
        closedImageView.tintColor = UIColor.white

        buttonsContainer.layer.cornerRadius = 12
        buttonsContainer.layer.masksToBounds = true

        addGestureRecognizers()

        activateConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        
        keyboardObserver.$keyboardOffset
            .sink { [weak self] in
                self?.keyboardDidShowOrHide(offset: $0)
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tools.addObserver(drawingView)
        tools.setVisible(true, forFirstResponder: drawingView)
        drawingView.becomeFirstResponder()
        setupHelpOverlay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubscribers()
    }

    @objc func showOrHideButtons() {
        if isShowingButtons {
            hideButtons()
        } else {
            showButtons()
        }
        isShowingButtons.toggle()
        openTapGestureRecognizer?.isEnabled = !isShowingButtons
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

    func buttonsViewConstraints() -> [NSLayoutConstraint] {
        guard let buttonsView = hostedButtonsViewController.view else { return [] }
        return [
            buttonsView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0)
        ]
    }

    func openArrowViewConstraints() -> [NSLayoutConstraint] {
        return [
            closedImageView.widthAnchor.constraint(equalToConstant: imageSizing.width),
            closedImageView.heightAnchor.constraint(equalToConstant: imageSizing.height)
        ]
    }

    func addSubscribers() {
        viewModel
            .drawingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.drawing, on: drawingView)
            .store(in: &cancellables)
    }

    func disableTranslatesAutoresizingMasksIntoConstraionts() {
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        hostedButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        closedImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func addSubViews() {
        view.addSubview(drawingView)
        view.addSubview(buttonsContainer)
        buttonsContainer.addSubview(buttonsVisualEffectView)
        buttonsContainer.addSubview(closedImageView)
        hostedButtonsViewController.embed(in: self, with: buttonsContainer, shouldPinToParent: false)
    }

    func activateConstraints() {
        NSLayoutConstraint.activate(buttonsVisualEffectView.pin(to: buttonsContainer))
        NSLayoutConstraint.activate(drawingViewConstraints())
        NSLayoutConstraint.activate(buttonContainerViewOpenedConstraints)
        NSLayoutConstraint.activate(buttonsViewConstraints())
        NSLayoutConstraint.activate(openArrowViewConstraints())
    }

    func addGestureRecognizers() {
        let swipGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showOrHideButtons))
        swipGestureRecognizer.direction = [.left, .right, .up, .down]
        buttonsContainer.addGestureRecognizer(swipGestureRecognizer)

        let openTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOrHideButtons))
        buttonsContainer.addGestureRecognizer(openTapGestureRecognizer)
        self.openTapGestureRecognizer = openTapGestureRecognizer
        self.openTapGestureRecognizer?.isEnabled = !isShowingButtons

    }

    func hideButtons() {
        NSLayoutConstraint.deactivate(buttonContainerViewOpenedConstraints)
        NSLayoutConstraint.activate(buttonsContainerViewClosedConstraints)

        self.closedImageView.isHidden = false
        self.closedImageView.transform = CGAffineTransform(rotationAngle: 180)
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 1.0) {
            self.buttonsContainer.layer.cornerRadius = (self.imageSizing.width) / 2
            self.closedImageView.alpha = 1.0
            self.closedImageView.transform = .identity
            self.hostedButtonsViewController.view.alpha = 0.0
            self.view.layoutIfNeeded()
        } completion: {
            if $0 {
                self.hostedButtonsViewController.view.isHidden = true
            }
        }
    }

    func showButtons() {
        NSLayoutConstraint.deactivate(buttonsContainerViewClosedConstraints)
        NSLayoutConstraint.activate(buttonContainerViewOpenedConstraints)

        self.hostedButtonsViewController.view.isHidden = false
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 1.0) {
            self.buttonsContainer.layer.cornerRadius = 12
            self.closedImageView.transform = CGAffineTransform(rotationAngle: 360)
            self.closedImageView.alpha = 0.0
            self.hostedButtonsViewController.view.alpha = 1.0
            self.view.layoutIfNeeded()
        } completion: {
            if $0 {
                self.closedImageView.isHidden = true
                self.closedImageView.transform = .identity
            }
        }
    }
    
    func keyboardDidShowOrHide(offset: CGFloat) {
        buttonsContainerBottomConstraint?.constant = offset - 12
        view.setNeedsLayout()
        buttonsContainer.setNeedsLayout()
        
        UIView.animate(withDuration: keyboardObserver.duration) {
            self.view.layoutIfNeeded()
            self.buttonsContainer.layoutIfNeeded()
        } completion: {
            if $0 {
                if self.keyboardObserver.keyboardOffset == 0 {
                    self.drawingView.becomeFirstResponder()
                }
            }
        }
    }
    
    func setupHelpOverlay() {
        let titles = viewModel.leadingButtons().map { $0.description ?? "Button" } + ["Total time recorded", "Edit title", "Skip"] + viewModel.trailingButtons().map { $0.description ?? "Button" }
        guard let buttonSubviews = hostedButtonsViewController.view.subviews.first?.subviews else {
            return
        }
        
        let models = zip(buttonSubviews, titles)
            .map {(viewAndString) -> HelpOverlayViewModel in
                let (subView, title) = viewAndString
                let rect = view.convert(subView.frame, from: subView.superview)
                return HelpOverlayViewModel(rect: rect, title: title)
            }
        
        let helpOverlayView = HelpOverlayView(viewModels: models)
        self.helpOverlayView = helpOverlayView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideHelpOverlay))
        helpOverlayView.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(helpOverlayView)
        helpOverlayView.frame = view.bounds
        
        helpOverlayView.alpha = 0
        helpOverlayView.isHidden = true
    }
    
    func showOrHideHelpOverlayView(show: Bool) {
        if show {
            helpOverlayView?.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.helpOverlayView?.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.helpOverlayView?.alpha = 0.0
            } completion: { _ in
                self.helpOverlayView?.isHidden = true
            }
        }
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
    
    func showHelpOverlay() {
        showOrHideHelpOverlayView(show: true)
    }
    
    @objc func hideHelpOverlay() {
        showOrHideHelpOverlayView(show: false)
    }
}
