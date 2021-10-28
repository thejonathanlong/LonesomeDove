//
//  DrawingViewController.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import UIKit
import PencilKit

// MARK: - DrawingViewControllerDisplayable
protocol DrawingViewControllerDisplayable {
    func didUpdate(drawing: PKDrawing)
}

// MARK: - DrawingViewController
class DrawingViewController: UIViewController, PKCanvasViewDelegate {
    //MARK:  - Properties
    private let viewModel: DrawingViewControllerDisplayable
    private let drawingView = PKCanvasView()
    private let tools = PKToolPicker()
    
    //MARK: - Init
    init(viewModel: DrawingViewControllerDisplayable) {
        self.viewModel = viewModel
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
        view.addSubview(drawingView)
        NSLayoutConstraint.activate(drawingView.pin(to: view))
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

//MARK: - PKCanvasViewDelegate
extension DrawingViewController {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.didUpdate(drawing: canvasView.drawing)
    }
}
