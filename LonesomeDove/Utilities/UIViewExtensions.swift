//
//  UIViewExtensions.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import UIKit

extension UIView {
    func pin(to view: UIView) -> [NSLayoutConstraint]{
        self.translatesAutoresizingMaskIntoConstraints = false
        return [
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
    }
}
