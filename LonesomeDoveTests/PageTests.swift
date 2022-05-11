//
//  PageTests.swift
//  LonesomeDoveTests
//
//  Created on 4/2/22.
//

import Collections
@testable import LonesomeDove
import PencilKit
import XCTest

class PageTests: XCTestCase {

    func testInit() {
        let expectedDrawing = PKDrawing()
        let expectedIndex = 0
        let expectedURLs = OrderedSet<URL?>([
            FileManager.default.temporaryDirectory.appendingPathComponent("blah")
        ])
        let expectedStickers = Set(arrayLiteral: Sticker(stickerData: Data(), creationDate: Date(), stickerImage: UIImage(), position: .zero, pageIndex: 0, storyName: "Hello"))
        let expectedText = PageText(text: "blah", type: .generated, position: .zero)
        let page = Page(drawing: expectedDrawing, index: expectedIndex, recordingURLs: expectedURLs, stickers: expectedStickers, pageText: expectedText)
        
        XCTAssertEqual(page.drawing, expectedDrawing)
        XCTAssertEqual(page.index, expectedIndex)
        XCTAssertEqual(page.recordingURLs, expectedURLs)
        XCTAssertEqual(page.stickers, expectedStickers)
        XCTAssertEqual(page.text, expectedText)
    }
    
    func testInitWithManagedObject() throws {
        let expectedDrawing = PKDrawing()
        let expectedIndex = 0
        let expectedURLs = OrderedSet<URL?>([
            FileManager.default.temporaryDirectory.appendingPathComponent("blah")
        ])
        let expectedSticker = Sticker(stickerData: Data(), creationDate: Date(), stickerImage: UIImage(named: "test_image"), position: .zero, pageIndex: 0, storyName: "Hello")
        let expectedStickers = Set<Sticker>(arrayLiteral: expectedSticker)
        let expectedText = PageText(text: "blah", type: .generated, position: .zero)
        let dataStore = DataStore()
        
        let pageManagedObject = try  XCTUnwrap(PageManagedObject(managedObjectContext: dataStore.persistentContainer.viewContext,
                                                  audioLastPathComponents: expectedURLs.compactMap { $0?.path },
                                                  illustration: expectedDrawing.dataRepresentation(),
                                                  number: Int16(expectedIndex),
                                                  posterImage: nil,
                                                  text: PageTextManagedObject(managedObjectContext: dataStore.persistentContainer.viewContext,
                                                                              text: expectedText.text,
                                                                              type: expectedText.type,
                                                                              page: nil,
                                                                              position: expectedText.position), stickers: [StickerManagedObject(managedObjectContext: dataStore.persistentContainer.viewContext, drawingData: expectedSticker.stickerData, imageData: expectedSticker.stickerImage?.pngData(), creationDate: expectedSticker.creationDate, position: expectedSticker.position)].compactMap { $0 }
        ))
        
        let page = try XCTUnwrap(Page(pageManagedObject: pageManagedObject))
        
        XCTAssertEqual(page.drawing, expectedDrawing)
        XCTAssertEqual(page.index, expectedIndex)
        zip(page.recordingURLs, expectedURLs).forEach {
            XCTAssertEqual($0.0?.lastPathComponent, $0.1?.lastPathComponent)
        }
        zip(page.stickers, expectedStickers).forEach {
            XCTAssertEqual($0.0.creationDate, $0.1.creationDate)
            XCTAssertEqual($0.0.stickerData, $0.1.stickerData)
            XCTAssertEqual($0.0.position, $0.1.position)
        }
        XCTAssertEqual(page.text, expectedText)
    }

}
