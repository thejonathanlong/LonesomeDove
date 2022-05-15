//
//  DeletableTextField.swift
//  LonesomeDove
//
//  Created on 5/14/22.
//

import Foundation
import UIKit

class DeletableTextField: UIView, UITextFieldDelegate {
    var textField: UITextField
    
    var deleteButton: UIButton?
    
    weak var delegate: UITextFieldDelegate?
    
    var text: String? {
        didSet {
            textField.text = text
        }
    }
    
    override init(frame: CGRect) {
        textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        textField.textColor = UIColor.black
        deleteButton = nil
        super.init(frame: frame)
        textField.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height).insetBy(dx: 8, dy: 8)
        addSubview(textField)
    }
    
    public convenience init(deleteActionHandler: ((UIAction) -> Void)? = nil) {
        self.init(frame: .zero)
        
        if let deleteActionHandler = deleteActionHandler, let deleteImage = UIImage(systemName: "xmark.circle.fill")?
            .withTintColor(.red) {
            let deleteAction = UIAction(handler: deleteActionHandler)
            let deleteButton = UIButton(primaryAction: deleteAction)
            deleteButton.setImage(deleteImage, for: .normal)
            deleteButton.tintColor = .red
            deleteButton.frame = CGRect(x: 0, y: 0, width: deleteImage.size.width, height: deleteImage.size.height)
            deleteButton.center = CGPoint(x: textField.frame.minX - 3, y: textField.frame.minY - 3)
            addSubview(deleteButton)
            self.deleteButton = deleteButton
            self.deleteButton?.isHidden = true
            self.deleteButton?.alpha = 0.0
            
            textField.delegate = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeToFit() {
        textField.sizeToFit()
        frame = CGRect(x: frame.minX, y:frame.minY, width: textField.frame.width + 16, height: textField.frame.height + 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds.insetBy(dx: 8, dy: 8)
        deleteButton?.center = CGPoint(x: textField.frame.minX - 3, y: textField.frame.minY - 3)
    }
}

//MARK: - UITextFieldDelegate
extension DeletableTextField {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == self.textField else { return }
        
        deleteButton?.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.deleteButton?.alpha = 1.0
        }
        
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == self.textField else { return }

        UIView.animate(withDuration: 0.25) {
            self.deleteButton?.alpha = 0.0
        } completion: { completed in
            if completed {
                self.deleteButton?.isHidden = true
            }
        }
        
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.textFieldDidChangeSelection?(textField)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldClear?(textField) ?? true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn?(textField) ?? true
    }
}
