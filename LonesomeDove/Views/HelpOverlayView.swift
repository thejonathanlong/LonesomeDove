//
//  HelpOverlayView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/1/22.
//

import UIKit
import SwiftUI
import SwiftUIFoundation

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

    var viewModelIterator: IndexingIterator<[HelpOverlayViewModel]>

    var currentShowingArrow: ArrowView?

    var arrowViews = [ArrowView]()

    let backgroundView = UIView()

    let introHostingController: HostedViewController<InfoDialogView>

    init(viewModels: [HelpOverlayViewModel]) {
        self.viewModels = viewModels
        self.viewModelIterator = viewModels.makeIterator()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        self.introHostingController = HostedViewController(contentView: InfoDialogView(title: "Create your first story!", description: "Time to create your first story! Illustrate each page and record a vivid fantasy of your own!\nTap to continue."), backgroundView: backgroundView)
        super.init(frame: .zero)

        backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        addSubview(introHostingController.view)
        introHostingController.view.sizeToFit()
        introHostingController.view.frame = CGRect(x: 0, y: 0, width: introHostingController.view.intrinsicContentSize.width, height: introHostingController.view.intrinsicContentSize.height)
    }

    func showNext() -> Bool? {
        guard let next = viewModelIterator.next() else {
            return false
        }

        introHostingController.view.isHidden = true
        currentShowingArrow?.removeFromSuperview()

        if next.rect.minX > (frame.size.width / 2.0) {
            let arrowView = ArrowView(text: next.title, alignment: .trailing)
            arrowView.frame = CGRect(x: next.rect.minX - arrowView.label.frame.width + 10,
                                     y: next.rect.minY - (frame.height - next.rect.minY)/2 - 40,
                                     width: arrowView.label.frame.width,
                                     height: (frame.height - next.rect.minY)/2 + 20)
            addSubview(arrowView)
            currentShowingArrow = arrowView
        } else {
            let arrowView = ArrowView(text: next.title, alignment: .leading)
            arrowView.frame = CGRect(x: next.rect.minX,
                                     y: next.rect.minY - (frame.height - next.rect.minY)/2 - 40,
                                     width: arrowView.label.frame.width,
                                     height: (frame.height - next.rect.minY)/2 + 20)
            addSubview(arrowView)
            currentShowingArrow = arrowView
        }

        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        introHostingController.view.center = center
    }
}

class ArrowView: UIView {

    let label = UILabel()
    let imageView = UIImageView()
    let arrowImage = UIImage(systemName: "arrow.down")
    let stackView = UIStackView()

    var text: String

    lazy var labelConstraints: [NSLayoutConstraint] = {
        [
            label.heightAnchor.constraint(equalToConstant: 100),
            label.widthAnchor.constraint(equalToConstant: 100)
        ]
    }()

    lazy var stackViewConstraints: [NSLayoutConstraint] = {
        [stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        stackView.topAnchor.constraint(equalTo: topAnchor),
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor)]
    }()

    lazy var imageViewConstraints: [NSLayoutConstraint] = {
        guard let arrowImage = arrowImage else {
            return []
        }

        return [imageView.widthAnchor.constraint(equalToConstant: arrowImage.size.width * 2),
         imageView.heightAnchor.constraint(equalToConstant: arrowImage.size.height * 2)]
    }()

    init(text: String, alignment: UIStackView.Alignment) {
        self.text = text
        super.init(frame: .zero)

        imageView.image = arrowImage
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white

        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.text = text
        label.numberOfLines = 2
        label.textColor = .white
        label.sizeToFit()
        label.setContentHuggingPriority(.required, for: .vertical)

        stackView.axis = .vertical
        stackView.alignment = alignment
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(imageView)

        addSubview(stackView)

        NSLayoutConstraint.activate(stackViewConstraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
