//
//  StickerState.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Combine
import UIKit

enum StickerAction: CustomStringConvertible {
    /// Save
    /// param: Data - The PKDrawingData
    ///  param: Data - The Image Data
    ///  param: Date - The creation date
    case save(Data, Data, Date, UUID)
    case fetchStickers
    case updateStickers([Sticker])
    case showStickerDrawer
    case addStickerToStory(StickerDisplayable)

    var description: String {
        var base = "StickerAction "

        switch self {
        case .save(let drawingData, let imageData, let date, let uuid):
            base += "Save date: \(date), drawingData: \(drawingData.count) imageData: \(imageData.count), id: \(uuid)"

        case .fetchStickers:
            base += "Fetch Stickers"

        case .updateStickers(let stickers):
            base += "Update Stickers \(stickers)"

        case .showStickerDrawer:
            base += "Show Sticker Drawer"

        case .addStickerToStory(let stickerDisplayable):
            base += "Add Sticker to Story creationDate: \(stickerDisplayable.creationDate), stickerData: \(stickerDisplayable.stickerData.count), pageIndex: \(stickerDisplayable.pageIndex ?? -1) position: \(stickerDisplayable.position)"
        }

        return base
    }
}

struct StickerState {

    enum Error: LocalizedError {
        case badStickerData

        var warning: Route.Warning {
            switch self {
                case .badStickerData:
                    return Route.Warning.badStickerData
            }
        }
    }

    var stickers = CurrentValueSubject<[Sticker], Never>([])

    func showDrawer() {
        AppLifeCycleManager.shared.router.route(to: .showStickerDrawer(stickers.value))
    }

    func addStickerToStory(_ sticker: StickerDisplayable, named: String) {
        var sticker = sticker
        sticker.dateAdded = Date()
        sticker.storyName = named
        AppLifeCycleManager.shared.router.route(to: .addStickerToStory(sticker))
    }
}

func stickerReducer(state: inout AppState, action: StickerAction) {
    switch action {
        case .save(let drawingData, let imageData, let creationDate, let uuid):
            state.dataStore.addSticker(drawingData: drawingData,
                                       imageData: imageData,
                                       creationDate: creationDate,
                                       id: uuid,
                                       dateAdded: nil,
                                       position: .zero,
                                       pageIndex: nil)

        case .fetchStickers:
            break

        case .updateStickers(let newStickers):
            state.stickerState.stickers.value = newStickers

        case .showStickerDrawer:
            state.stickerState.showDrawer()

        case .addStickerToStory(var displayable):
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({
            }))
            state.stickerState.addStickerToStory(displayable, named: state.storyCreationState.currentName ?? "🐛🐛🐛")
            displayable.storyName = state.storyCreationState.currentName ?? "🐛🐛🐛"
            
            var displayable = displayable
            displayable.pageIndex = state.storyCreationState.currentPage.index
            if let sticker = displayable as? Sticker {
                state.storyCreationState.currentPage.stickers.insert(sticker)
            }
    }
}
