//
//  StickerState.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Combine
import UIKit

enum StickerAction {
    case save(Data, Data, Date)
    case fetchStickers
    case updateStickers([Sticker])
    case showStickerDrawer
    case addSticker(StickerDisplayable)
}

struct StickerState {
    var stickers = CurrentValueSubject<Array<Sticker>, Never>([])
    
    func showDrawer() {
        AppLifeCycleManager.shared.router.route(to: .showStickers(stickers.value))
    }
    
    func addSticker(stickerDisplayable: StickerDisplayable) {
        
    }
}

func stickerReducer(state: inout AppState, action: StickerAction) {
    switch action {
        case .save(let drawingData, let imageData, let creationDate):
            state.dataStore.addSticker(drawingData: drawingData, imageData: imageData, creationDate: creationDate)
        
        case .fetchStickers:
            break
        
        case .updateStickers(let newStickers):
            state.stickerState.stickers.value = newStickers
        
        case .showStickerDrawer:
            state.stickerState.showDrawer()
            
        case .addSticker(let displayable):
            state.stickerState.addSticker(stickerDisplayable: displayable)
        
    }
}
