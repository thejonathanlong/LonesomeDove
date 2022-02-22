//
//  DataStoreTests.swift
//  LonesomeDoveTests
//
//  Created on 2/20/22.
//

import Collections
@testable import LonesomeDove
import PencilKit
import XCTest

class DataStoreTests: XCTestCase {
    
    lazy var stickerFactory: TestStickerFactory = {
        TestStickerFactory(store: store)
    }()
    
    lazy var pageFactory: TestPageFactory = {
        TestPageFactory(store: store, stickerFactory: stickerFactory)
    }()
    
    var store = DataStore()
    
    func testAddSticker() throws {
        let drawingData = "blah".data(using: .utf8)!
        let imageData = UIImage(named: "test_image")?.pngData()
        let creationDate = Date()
        let sticker = try XCTUnwrap(stickerFactory.makeSticker(drawingData: drawingData, imageData: imageData, creationDate: creationDate))
        
        XCTAssertEqual(sticker.drawingData, drawingData)
        XCTAssertEqual(sticker.imageData, imageData)
        XCTAssertEqual(sticker.creationDate, creationDate)
    }
    
    func testAddDraft() throws {
        let store = DataStore()
        let _ = try addDraft(named: "Hello World", in: store)
    }
    
    func testUpdateDraft() async throws {
        let store = DataStore()
        let name = "Hello World"
        let oldStickers = [
            TestStickerFactory.TestStickerConfiguration(imageData: "jonathan".data(using: .utf8)!, drawingData: "helloworld".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 16, y: 19)),
            TestStickerFactory.TestStickerConfiguration(imageData: "jimbo".data(using: .utf8)!, drawingData: "kangaroo".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 160, y: 190)),
        ]
        let oldPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]), stickers: [oldStickers[0]]),
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("y")]), stickers: [oldStickers[1]]),
        ]

        let draft = try addDraft(named: name, in: store, with: oldPageConfigurations, stickers: oldStickers)
        
        let newName = "Hello Bobby"
        let newStickers = [
            TestStickerFactory.TestStickerConfiguration(imageData: UIImage(named: "test_image")!.pngData(),
                                                        drawingData: "helloworld".data(using: .utf8)!,
                                                        creationDate: Date(),
                                                        position: CGPoint(x: 6, y: 9)),
            TestStickerFactory.TestStickerConfiguration(imageData: UIImage(named: "test_image")!.pngData(),
                                                        drawingData: "helloworld".data(using: .utf8)!,
                                                        creationDate: Date(),
                                                        position: CGPoint(x: 6, y: 9)),
            TestStickerFactory.TestStickerConfiguration(imageData: UIImage(named: "test_image")!.pngData(),
                                                        drawingData: "helloworld".data(using: .utf8)!,
                                                        creationDate: Date(), position: CGPoint(x: 6, y: 9)),
        ]
        
        let newPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(4),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: oldPageConfigurations[0].stickers + [newStickers[0]]),
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("y")]),
                                                 stickers: oldPageConfigurations[1].stickers + [newStickers[1]]),
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(5),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("z")]),
                                                 stickers: [newStickers[2]]),
        ]
        let newPages = try pageFactory.makeSomePages(configurations: newPageConfigurations)
        await store.updateDraft(named: name, newName: newName, pages: newPages)
        
        draft.pages?
            .compactMap {
                $0 as? PageManagedObject
            }
            .enumerated()
            .forEach{ tup in
                let pmo = tup.element
                    .pages?
                    .compactMap { $0 as? PageManagedObject }[tup.offset]
                let pageConfig = newPageConfigurations[tup.offset]
                let lastPaths = pmo?.audioLastPathComponents as? Array<String>
                pageConfig.recordingURLs.compactMap { $0 }.forEach {
                    XCTAssertTrue(lastPaths?.contains($0.lastPathComponent) ?? false)
                }
                XCTAssertEqual(pageConfig.drawing.dataRepresentation(), pmo?.illustration)
                let smos = pmo?.stickers as? Set<StickerManagedObject>
                
                pageConfig.stickers.forEach { sticker in
                    let res = smos?.compactMap { $0 }.filter { smo in
                        (smo.creationDate ?? Date()) == sticker.creationDate &&
                        NSCoder.string(for: sticker.position) == smo.position &&
                        sticker.drawingData == smo.drawingData &&
                        sticker.imageData == smo.imageData
                    }
                    
                    XCTAssertEqual(res?.count, 1)
                }
            }
    }
    
    func testAddStory() {
        let store = DataStore()
        let url = FileManager.documentsDirectory.appendingPathComponent("story")
        let storyName = "My Story"
        let storyMO = store.addStory(named: storyName,
                                     location:url,
                                     duration: 10,
                                     numberOfPages: 4)
        XCTAssertEqual(storyMO?.title, storyName)
        XCTAssertEqual(storyMO?.lastPathComponent, url.lastPathComponent)
        XCTAssertEqual(storyMO?.duration, 10)
        XCTAssertEqual(storyMO?.numberOfPages, 4)
        XCTAssertNotNil(storyMO?.date)
    }
    
    func addDraft(named: String,
                  in store: DataStore,
                  with pageConfigs: [TestPageFactory.TestPagConfiguration]? = nil,
                  stickers: [TestStickerFactory.TestStickerConfiguration]? = nil) throws -> DraftStoryManagedObject {
        let pages = pageConfigs != nil ? try pageFactory.makeSomePages(configurations: pageConfigs!) : try pageFactory.makeSomePages(number: 2)
        let stickers = pages.map { Array($0.stickers) }.flatMap { $0 }
        let draft = try XCTUnwrap(store.addDraft(named: named, pages: pages, stickers: stickers))
        
        XCTAssertEqual(draft.pages?.count, 2)
        XCTAssertEqual(draft.title, named)
        XCTAssertEqual(draft.stickers?.count, 2)
        
        let stickerCheck = draft.stickers?
            .compactMap { $0 as? StickerManagedObject }
            .map { smo in
                stickers.filter { sticker in
                    sticker == smo
                }
            }
            .flatMap{ $0 }
        
        XCTAssertEqual(stickerCheck?.count, draft.stickers?.count)
        
        let pageManagedObjects = draft.pages?
            .compactMap { $0 as? PageManagedObject }
        
        zip(pageManagedObjects ?? [], pages)
            .forEach { (pmo, page) in
                XCTAssertEqual(pmo.stickers?.count, page.stickers.count)
            }
        
        let pageCheck = draft.pages?
            .compactMap { $0 as? PageManagedObject }
            .map { pmo in
                pages.filter { page in
                    page == pmo
                }
            }
            .flatMap { $0 }
        
        XCTAssertEqual(pageCheck?.count, 2)
        
        return draft
    }
}
