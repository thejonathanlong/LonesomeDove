//
//  StickerState.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Combine
import UIKit

enum StickerAction {
    case save(UIImage)
    case fetchStickers
    case updateStickers([Sticker])
    case showStickerDrawer
}

struct StickerState {
    var stickers = CurrentValueSubject<Array<Sticker>, Never>([])
    
    func showDrawer() {
        AppLifeCycleManager.shared.router.route(to: .showStickers(stickers.value))
    }
}

func stickerReducer(state: inout AppState, action: StickerAction) {
    switch action {
        case .save(let image):
            if let data = image.pngData() {
                state.dataStore.addSticker(drawingData: data)
            }
        
        case .fetchStickers:
            break
        
        case .updateStickers(let newStickers):
            state.stickerState.stickers.value = newStickers
        
        case .showStickerDrawer:
            state.stickerState.showDrawer()
        
    }
}
