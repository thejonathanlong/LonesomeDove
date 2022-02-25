//
//  GestureRecognizerManager.swift
//  LonesomeDove
//
//  Created on 2/23/22.
//

import Foundation
import UIKit

class GestureRecognizerManager: NSObject, UIGestureRecognizerDelegate {
        
    func add(_ view: UIView) {
        view.isUserInteractionEnabled = true
        addPanGestureRecognizer(to: view)
        addPinchGestureRecognizer(to: view)
        addRotationGestureRecognizer(to: view)
    }
    
    @objc func handle(panGestureRecognizer: UIPanGestureRecognizer) {
        guard let view = panGestureRecognizer.view else { return }
        
        switch panGestureRecognizer.state {
            case .changed:
                let translation = panGestureRecognizer.translation(in: view.superview)
                view.center = view.center + translation
                panGestureRecognizer.setTranslation(.zero, in: view.superview)
                
            default:
                break
        }
    }
    
    @objc func handle(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = pinchGestureRecognizer.view else { return }
        
        let scale = pinchGestureRecognizer.scale
        switch pinchGestureRecognizer.state {
            case .began:
                view.transform = view.transform.scaledBy(x: scale, y: scale)
                
            case .changed:
                view.transform = view.transform.scaledBy(x: scale, y: scale)
            
            default:
                break
        }
        
        pinchGestureRecognizer.scale = 1.0
    }
    
    @objc func handle(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        guard let view = rotationGestureRecognizer.view else { return }
        
        view.transform = view.transform.rotated(by: rotationGestureRecognizer.rotation)
        rotationGestureRecognizer.rotation = 0
    }
}

//MARK: - UIGestureRecognizerDelegate
extension GestureRecognizerManager {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

//MARK: - Private
private extension GestureRecognizerManager {
    func addPanGestureRecognizer(to view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(panGestureRecognizer:)))
        panGestureRecognizer.delegate = self
        
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func addPinchGestureRecognizer(to view: UIView) {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handle(pinchGestureRecognizer:)))
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func addRotationGestureRecognizer(to view: UIView) {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handle(rotationGestureRecognizer:)))
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
    }
}

//MARK: - CGPoint Extension
extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
