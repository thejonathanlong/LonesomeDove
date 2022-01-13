//
//  UIViewControllerExtensions.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 11/4/21.
//

import UIKit

extension UIViewController {
    func embed(in parentViewController: UIViewController, with parentView: UIView, shouldPinToParent: Bool = true) {
        willMove(toParent: parentViewController)
        view.willMove(toSuperview: parentView)
        parentViewController.addChild(self)
        parentView.addSubview(view)
        didMove(toParent: parentViewController)
        view.didMoveToSuperview()

        if shouldPinToParent {
            NSLayoutConstraint.activate(view.pin(to: parentView))
        }
    }
}
