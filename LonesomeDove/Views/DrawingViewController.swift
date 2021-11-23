//
//  DrawingViewController.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import UIKit
import PencilKit
import SwiftUIFoundation

// MARK: - DrawingViewControllerDisplayable
protocol DrawingViewControllerDisplayable {
    func didUpdate(drawing: PKDrawing)
    func buttons() -> [ButtonViewModel]
}

// MARK: - DrawingViewController
class DrawingViewController: UIViewController, PKCanvasViewDelegate {
    //MARK:  - Properties
    private let viewModel: DrawingViewControllerDisplayable
    private let drawingView = PKCanvasView()
    private let tools = PKToolPicker()
    private let hostedButtonsViewController: HostedViewController<UtilityButtons>
    private let buttonsContainer = UIView()
    
    //MARK: - Init
    init(viewModel: DrawingViewControllerDisplayable) {
        self.viewModel = viewModel
        let someView = UIView()
        someView.backgroundColor = UIColor.white
        someView.backgroundColor = UIColor.blue
        self.hostedButtonsViewController = HostedViewController(contentView: UtilityButtons(viewModels: viewModel.buttons()),
                                                                alignment: .leading)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UIView
extension DrawingViewController {
    override func loadView() {
        super.loadView()
        drawingView.delegate = self
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(drawingView)
        view.addSubview(buttonsContainer)
        buttonsContainer.backgroundColor = UIColor.blue
        hostedButtonsViewController.embed(in: self, with: buttonsContainer)
        
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
}

//MARK: - Private
private extension DrawingViewController {
    func drawingViewConstraints() -> [NSLayoutConstraint] {
        [
            drawingView.topAnchor.constraint(equalTo: view.topAnchor),
            drawingView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 16.0 / 9.0),
            drawingView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -100)
        ]
    }
    
    func buttonContainerViewConstraints() -> [NSLayoutConstraint] {
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        return [
            buttonsContainer.topAnchor.constraint(equalTo: drawingView.bottomAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
    }
    
    func buttonsViewConstraints() -> [NSLayoutConstraint] {
        guard let buttonsView = hostedButtonsViewController.view else { return [] }
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        return [
            buttonsView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25.0),
            buttonsView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -25.0)
        ]
    }
}

//MARK: - PKCanvasViewDelegate
extension DrawingViewController {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.didUpdate(drawing: canvasView.drawing)
    }
}
