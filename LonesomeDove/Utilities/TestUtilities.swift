//
//  TestUtilities.swift
//  LonesomeDoveTests
//
//  Created on 2/21/22.
//

import Collections
import Foundation
@testable import LonesomeDove
import PencilKit
import XCTest

extension Sticker {
    static func == (lhs: Sticker, rhs: StickerManagedObject) -> Bool {
        lhs.creationDate == rhs.creationDate && NSCoder.string(for: lhs.position) == rhs.position && lhs.stickerData == rhs.drawingData
    }
}

extension Page {
    static func == (lhs: Page, rhs: PageManagedObject) -> Bool {
        lhs.index == rhs.number &&
        lhs.drawing.dataRepresentation() == rhs.illustration &&
        lhs.recordingURLs.compactMap { $0?.lastPathComponent }.map { NSString(string: $0) } == rhs.audioLastPathComponents as? [NSString]
    }
}

extension PKDrawing {
    static func drawingWithStrokes(_ strokeCount: Int) -> PKDrawing {
        var d = PKDrawing()
        let path = PKStrokePath(controlPoints: [PKStrokePoint(location: .zero, timeOffset: 0, size: .zero, opacity: 1.0, force: 1.0, azimuth: 1.0, altitude: 1.0)], creationDate: Date())
        let stroke = PKStroke(ink: PKInk(.marker, color: .red), path: path)
        
        d.strokes.append(contentsOf: Array(repeating: stroke, count: strokeCount))
        
        return d
    }
}

struct TestStickerFactory {
    
    let store: DataStore
    
    struct TestStickerConfiguration {
        let imageData: Data?
        let drawingData: Data
        let creationDate: Date
        let position: CGPoint
    }
    
    func makeSticker(drawingData: Data, imageData: Data?, creationDate: Date) throws -> StickerManagedObject {
        return try XCTUnwrap(store.addSticker(drawingData: drawingData, imageData: imageData, creationDate: creationDate, position: .zero))
    }
    
    func makeSticker(configuration: TestStickerConfiguration) throws -> StickerManagedObject {
        return try XCTUnwrap(store.addSticker(drawingData: configuration.drawingData, imageData: configuration.imageData, creationDate: configuration.creationDate, position: configuration.position))
    }
}

struct TestPageFactory {
    let store: DataStore
    let stickerFactory: TestStickerFactory
    let defaultDrawing = PKDrawing()
    let defaultRecordingURLs = OrderedSet([URL(string:NSTemporaryDirectory())])
    
    struct TestPagConfiguration {
        let drawing: PKDrawing
        let recordingURLs: OrderedSet<URL?>
        let stickers: [TestStickerFactory.TestStickerConfiguration]
    }
    
    init(store: DataStore, stickerFactory: TestStickerFactory) {
        self.store = store
        self.stickerFactory = stickerFactory
    }
    
    func makeSomePages(number: Int) throws -> [Page] {
        var pages: [Page] = []
        for i in 0..<number {
            let sticker = try XCTUnwrap(Sticker(sticker: try stickerFactory.makeSticker(drawingData: Data(),
                                                                      imageData: Data(),
                                                                      creationDate: Date()), pageIndex: i))
            let page = Page(drawing: defaultDrawing,
                            index: i,
                            recordingURLs: defaultRecordingURLs,
                            stickers: Set([sticker]))
            pages.append(page)
        }
        return pages
    }
    
    func makeSomePages(configurations: [TestPagConfiguration]) throws -> [Page] {
        try configurations.enumerated().map { pageTuple in
            let stickers = try pageTuple.element.stickers
                .map { stickerConfig in
                    try stickerFactory.makeSticker(configuration: stickerConfig)
                }
                .compactMap {
                    Sticker(sticker: $0, pageIndex: pageTuple.offset)
                }
            let page = Page(drawing: pageTuple.element.drawing,
                        index: pageTuple.offset,
                        recordingURLs: pageTuple.element.recordingURLs,
                        stickers: Set(stickers))
            return page
        }
    }
}
