//
//  TextFieldViewModel.swift
//  LonesomeDove
//
//  Created on 1/29/22.
//

import Foundation

class TextFieldViewModel: ObservableObject {
    @Published var text: String = ""
    var placeholder: String
    
    init(placeholder: String) {
        self.placeholder = placeholder
    }
}
