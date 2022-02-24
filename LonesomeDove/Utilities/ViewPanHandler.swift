//
//  ViewPanHandler.swift
//  LonesomeDove
//
//  Created on 2/23/22.
//

import Foundation
import UIKit

class ViewPanHandler: NSObject, UIGestureRecognizerDelegate {
        
    func add(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(panGestureRecognizer:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
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
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
