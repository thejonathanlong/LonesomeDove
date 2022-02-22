//
//  StickerGridViewModel.swift
//  LonesomeDove
//
//  Created on 2/15/22.
//

import UIKit

protocol StickerDisplayable {
    var stickerImage: UIImage? { get }
    var stickerData: Data { get }
    var creationDate: Date { get }
    var pageIndex: Int? { get }
    var position: CGPoint { get }
}

class StickersGridViewModel: ObservableObject {
    var stickerDisplayables: [StickerDisplayable]
    
    weak var store: AppStore? = nil
    
    var stickers: [UIImage] {
        stickerDisplayables.compactMap { $0.stickerImage }
    }
    
    init(stickerDisplayables: [StickerDisplayable]) {
        self.stickerDisplayables = stickerDisplayables.filter { $0.stickerImage != nil }
    }
    
    func didTap(stickerDisplayable: StickerDisplayable) {
        store?.dispatch(.sticker(.addSticker(stickerDisplayable)))
    }
}
