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
    var delegate: StoryCreationViewModelDelegate? { get set }
    var timerViewModel: TimerViewModel? { get }
    var storyNameViewModel: TextFieldViewModel { get set }
    var pageNumber: Int { get }
    func didUpdate(drawing: PKDrawing)
    func leadingButtons() -> [ButtonViewModel]
    func trailingButtons() -> [ButtonViewModel]
    func didFinishHelp()
    func textDidEndEditing(text: String, position: CGPoint)
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

    private let gestureRecognizerManager = GestureRecognizerManager()

    private var oldTextFieldFrame: CGRect?

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

    private lazy var textField: UITextField = {
        let label = UITextField()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = UIColor.black
        label.sizeToFit()
        label.delegate = self

        drawingView.addSubview(label)
        label.center = drawingView.center

        gestureRecognizerManager.add(label)
        return label
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

// MARK: - Public
extension StoryCreationViewController {
    func add(sticker: StickerDisplayable) throws {
        guard let drawing = try? PKDrawing(data: sticker.stickerData) else {
            throw StickerState.Error.badStickerData
        }
        
        let image = drawing.image(from: drawing.bounds, scale: 1.0)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageView.center = sticker.position == .zero ? drawingView.center : sticker.position
        drawingView.addSubview(imageView)
        gestureRecognizerManager.add(imageView) { [weak self] point in
            self?.viewModel.update(sticker: sticker, position: point)
        }
    }

    func add(text: PageText?) {
        guard let text = text,
              text.text != textField.text else {
            return
        }
        textField.text = text.text
        textField.sizeToFit()
        textField.center = text.position ?? drawingView.center
    }
}

// MARK: - UIView
extension StoryCreationViewController {
    override func loadView() {
        super.loadView()
        drawingView.delegate = self
        drawingView.backgroundColor = .white

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tools.addObserver(drawingView)
        tools.setVisible(true, forFirstResponder: drawingView)
        drawingView.becomeFirstResponder()
        setupHelpOverlay()
        if viewModel.isFirstStory {
            showOrHideHelpOverlayView(show: true)
        }
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
            .assign(to: \.drawing, onWeak: drawingView)
            .store(in: &cancellables)

        viewModel
            .recognizedTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: add(text:))
            .store(in: &cancellables)
        
        viewModel
            .currentPagePublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] page in
                self?.drawingView
                    .subviews
                    .compactMap { $0 as? UIImageView }
                    .forEach { $0.removeFromSuperview() }
                page.stickers.forEach {
                    try? self?.add(sticker: $0)
                }
            }
            .store(in: &cancellables)

        keyboardObserver
            .$keyboardOffset
            .sink { [weak self] in
                self?.keyboardDidShowOrHide(offset: $0)
            }
            .store(in: &cancellables)

        keyboardObserver
            .$keyboardFrame
            .sink { [weak self] in
                guard let self = self,
                      let text = self.viewModel.recognizedTextPublisher.value?.text,
                      !text.isEmpty
                else { return }
                let frameInWindow = self.textField.convert(self.textField.bounds, to: self.view.window)
                if $0.intersects(frameInWindow) && $0.height != 0 {
                    self.oldTextFieldFrame = self.textField.frame
                    self.textField.frame = CGRect(x: self.textField.frame.minX,
                                                  y: $0.minY - 100,
                                                  width: self.textField.frame.width,
                                                  height: self.textField.frame.height)
                } else if let oldFrame = self.oldTextFieldFrame,
                          $0.height == 0.0 {
                    self.textField.frame = oldFrame
                }
            }
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
        guard let buttonSubviews = hostedButtonsViewController.view.subviews.first?.subviews else {
            return
        }

        let titles = viewModel.leadingButtons().map { $0.description ?? "Button" } + ["Edit title", "Skip", "Skip"] + viewModel.trailingButtons().map { $0.description ?? "Button" }

        let models = zip(buttonSubviews, titles)
            .compactMap {(viewAndString) -> HelpOverlayViewModel? in
                let (subView, title) = viewAndString
                guard title != "Skip" else { return nil }
                let rect = view.convert(subView.frame, from: subView.superview)
                return HelpOverlayViewModel(rect: rect, title: title)
            }

        let helpOverlayView = HelpOverlayView(viewModels: models)
        self.helpOverlayView = helpOverlayView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextHelp))
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

    @objc func nextHelp() {
        guard let helpOverlay = self.helpOverlayView,
              let didShowNext = helpOverlay.showNext(),
              didShowNext else {
                  hideHelpOverlay()
                  viewModel.didFinishHelp()
                  return
        }
    }

    func animateSave() {
        guard let subviews = hostedButtonsViewController.view.subviews.first?.subviews else { return }
        let imageView = UIImageView(image: currentImage())
        view.addSubview(imageView)
        imageView.frame = drawingView.frame

        var newFrame = CGRect.zero

        for (index, subView) in subviews.enumerated() {
            if index == 6 {
                let rect = view.convert(subView.frame, from: subView.superview)
                newFrame = rect
                break
            }
        }

        UIView.animate(withDuration: 0.5) {
            imageView.frame = newFrame
        } completion: { _ in
            imageView.removeFromSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate
extension StoryCreationViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        textField.sizeToFit()
        viewModel.textDidEndEditing(text: text, position: textField.center)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
