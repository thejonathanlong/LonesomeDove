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

    var arrowViews = [ArrowView]()

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
            viewModels.enumerated().forEach {
                let arrowView = ArrowView(text: $0.element.title)
                arrowView.frame = CGRect(x: $0.element.rect.minX,
                                         y: $0.element.rect.minY - (frame.height - $0.element.rect.minY)/2 * CGFloat(viewModels.count - ($0.offset + 1)) - 20,
                                         width: arrowView.label.frame.width,
                                         height: (frame.height - $0.element.rect.minY)/2 * CGFloat(viewModels.count - ($0.offset + 1)))
                arrowViews.append(arrowView)
                addSubview(arrowView)
            }
        }
    }

}

class ArrowView: UIView {

    let label = UILabel()
    let imageView = UIImageView()
    let arrowImage = UIImage(systemName: "arrow.down")
    let stackView = UIStackView()

    var text: String {
        didSet {
            label.text = text
        }
    }

    lazy var labelConstraints: [NSLayoutConstraint] = {
        [
            label.heightAnchor.constraint(equalToConstant: 30),
            label.widthAnchor.constraint(equalTo: widthAnchor)
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

    init(text: String) {
        self.text = text
        super.init(frame: .zero)

        imageView.image = arrowImage
        imageView.contentMode = .scaleAspectFit
//        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        imageView.translatesAutoresizingMaskIntoConstraints = false

        label.text = text
        label.textColor = .white
        label.sizeToFit()
        label.setContentHuggingPriority(.required, for: .vertical)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.sizeToFit()

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(imageView)

        addSubview(stackView)

        NSLayoutConstraint.activate(stackViewConstraints)
//        NSLayoutConstraint.activate(imageViewConstraints)

//        label.translatesAutoresizingMaskIntoConstraints = false
//        image.translatesAutoresizingMaskIntoConstraints
//        addSubview(label)
//        NSLayoutConstraint.activate(labelConstraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
