//
//  HelpOverlayView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/1/22.
//

import UIKit

struct HelpOverlayViewModel: Equatable {
    let rect: CGRect
    let title: String
}

class HelpOverlayView: UIView {

    var viewModels: [HelpOverlayViewModel] {
        didSet {
            arrowViews.forEach { $0.removeFromSuperview() }
        }
    }
    
    var arrowViews = Array<ArrowView>()
    
    let backgroundView = UIView()
    
    init(viewModels: [HelpOverlayViewModel]) {
        self.viewModels = viewModels
        super.init(frame: .zero)
        
        backgroundColor = UIColor.gray.withAlphaComponent(0.6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds

        if arrowViews.first?.superview != self {
            arrowViews = viewModels.map{
                let arrowView = ArrowView(text: $0.title)
                arrowView.frame = CGRect(x: $0.rect.minX, y: $0.rect.minY - $0.rect.height - 20, width: $0.rect.width, height: $0.rect.height)
                arrowView.backgroundColor = .red
                return arrowView
            }
            arrowViews.forEach {
                addSubview($0)
            }
        }
    }
    
}

class ArrowView: UIView {
    
    let label = UILabel()
    
    var text: String {
        didSet {
            label.text = text
        }
    }
    
    lazy var labelConstraints: [NSLayoutConstraint] = {
        [label.topAnchor.constraint(equalTo: topAnchor),
        label.leadingAnchor.constraint(equalTo: leadingAnchor),
         label.trailingAnchor.constraint(equalTo: trailingAnchor)]
    }()
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
