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
    var pageIndex: Int? { get set }
    var position: CGPoint { get set }
    var storyName: String? { get set }
    var dateAdded: Date? { get set }
    var id: UUID? { get set }
}

class StickersGridViewModel: ObservableObject {
    var stickerDisplayables: [StickerDisplayable]

    weak var store: AppStore?

    var stickers: [UIImage] {
        stickerDisplayables.compactMap { $0.stickerImage }
    }

    init(stickerDisplayables: [StickerDisplayable]) {
        self.stickerDisplayables = stickerDisplayables.filter { $0.stickerImage != nil }
    }

    func didTap(stickerDisplayable: StickerDisplayable) {
        store?.dispatch(.sticker(.addStickerToStory(stickerDisplayable)))
    }
}
