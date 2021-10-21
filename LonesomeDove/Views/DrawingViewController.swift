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
        
        let drawingView = PKCanvasView()
        drawingView.delegate = self
        view.addSubview(drawingView)
        
        NSLayoutConstraint.activate(drawingView.pin(to: view))
    }
}

//MARK: - PKCanvasViewDelegate
extension DrawingViewController {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewModel.didUpdate(drawing: canvasView.drawing)
    }
}
