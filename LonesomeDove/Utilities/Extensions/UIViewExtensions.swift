//
//  UIViewExtensions.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import UIKit
import SwiftUI

extension UIView {
    func pin(to view: UIView) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        return [
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }

    func align(to edges: Edge.Set, of view: UIView, with insets: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        if edges.contains(.leading) {
            let leadingConstraint = self.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                  constant: self.effectiveUserInterfaceLayoutDirection == .leftToRight ? insets.left : insets.right)
            constraints.append(leadingConstraint)
        }

        if edges.contains(.trailing) {
            let trailingConstraint = self.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                  constant: self.effectiveUserInterfaceLayoutDirection == .leftToRight ? -insets.right : -insets.left)
            constraints.append(trailingConstraint)
        }

        if edges.contains(.top) {
            let topConstraint = self.topAnchor.constraint(equalTo: view.topAnchor,
                                                              constant: insets.top)
            constraints.append(topConstraint)
        }

        if edges.contains(.bottom) {
            let bottomConstraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                  constant: -insets.bottom)
            constraints.append(bottomConstraint)
        }

        return constraints
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
