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
        _ = try addDraft(named: "Hello World", in: store)
    }

    func testUpdateDraftPages() async throws {
        let store = DataStore()
        let name = "Hello World"
        let oldPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]), stickers: [], pageText: nil)
        ]

        let draft = try addDraft(named: name, in: store, with: oldPageConfigurations)

        let newName = "Hello Bobby"

        let newPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: [],
                                                pageText: nil)
        ]
        let newPages = try pageFactory.makeSomePages(configurations: newPageConfigurations)
        await store.updateDraft(named: name, newName: newName, pages: newPages)

        XCTAssertEqual(draft.pages?.count, 1)
        let pageManagedObjects = try XCTUnwrap(draft.pages as? Set<PageManagedObject>)
        let sortedPageManagedObjects = pageManagedObjects.sorted { $0.number < $1.number }

        zip(sortedPageManagedObjects, newPageConfigurations)
            .forEach {
                XCTAssertEqual($0.0.illustration, $0.1.drawing.dataRepresentation())
                XCTAssertEqual($0.0.audioLastPathComponents as? [String], $0.1.recordingURLs.compactMap { $0?.lastPathComponent })
            }
    }

    func testUpdateDraftUpdatePageAddPage() async throws {

        let store = DataStore()
        let name = "Hello World"
        let oldPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]), stickers: [], pageText: nil)
        ]

        let draft = try addDraft(named: name, in: store, with: oldPageConfigurations)

        let newName = "Hello Bobby"

        let newPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: [],
                                                pageText: nil),
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: [],
                                                pageText: nil)
        ]
        let newPages = try pageFactory.makeSomePages(configurations: newPageConfigurations)
        await store.updateDraft(named: name, newName: newName, pages: newPages)

        XCTAssertEqual(draft.pages?.count, 2)
        let pageManagedObjects = try XCTUnwrap(draft.pages as? Set<PageManagedObject>)
        let sortedPageManagedObjects = pageManagedObjects.sorted { $0.number < $1.number }

        zip(sortedPageManagedObjects, newPageConfigurations)
            .forEach {
                XCTAssertEqual($0.0.illustration?.count, $0.1.drawing.dataRepresentation().count)
                XCTAssertEqual($0.0.audioLastPathComponents as? [String], $0.1.recordingURLs.compactMap { $0?.lastPathComponent })
            }
    }

    func testUpdateDraftUpdatePageWithStickers() async throws {
        let store = DataStore()
        let name = "Hello World"
        let oldStickers = [
            TestStickerFactory.TestStickerConfiguration(imageData: "jonathan".data(using: .utf8)!, drawingData: "helloworld".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 16, y: 19))
        ]
        let oldPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]), stickers: oldStickers, pageText: nil)
        ]

        let draft = try addDraft(named: name, in: store, with: oldPageConfigurations)

        let newName = "Hello Bobby"

        let newStickers = [TestStickerFactory.TestStickerConfiguration(imageData: "jonathan".data(using: .utf8)!, drawingData: "helloworld".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 16, y: 19))]
        let allStickers = oldStickers + newStickers

        let newPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: allStickers,
                                                 pageText: nil)
        ]

        let newPages = try pageFactory.makeSomePages(configurations: newPageConfigurations)
        await store.updateDraft(named: name, newName: newName, pages: newPages)

        XCTAssertEqual(draft.pages?.count, 1)
        XCTAssertEqual(draft.stickers?.count, 2)

        let pageManagedObjects = try XCTUnwrap(draft.pages as? Set<PageManagedObject>)
        let sortedPageManagedObjects = pageManagedObjects.sorted { $0.number < $1.number }
        zip(sortedPageManagedObjects, newPageConfigurations)
            .forEach {
                XCTAssertEqual($0.0.illustration, $0.1.drawing.dataRepresentation())
                XCTAssertEqual($0.0.audioLastPathComponents as? [String], $0.1.recordingURLs.compactMap { $0?.lastPathComponent })
            }

        let stickerManagedObjects = try XCTUnwrap(draft.stickers as? Set<StickerManagedObject>)
        let sortedStickerManageObjects = stickerManagedObjects.sorted { $0.creationDate! < $1.creationDate! }
        zip(sortedStickerManageObjects, allStickers)
            .forEach {
                XCTAssertEqual($0.0.creationDate, $0.1.creationDate)
                XCTAssertEqual($0.0.drawingData?.count, $0.1.drawingData.count)
                XCTAssertEqual($0.0.position, NSCoder.string(for: $0.1.position))
            }
    }

    func testFullUpdateDraft() async throws {
        let store = DataStore()
        let name = "Hello World"
        let oldStickers = [
            TestStickerFactory.TestStickerConfiguration(imageData: "jonathan".data(using: .utf8)!, drawingData: "helloworld".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 16, y: 19)),
            TestStickerFactory.TestStickerConfiguration(imageData: "blah".data(using: .utf8)!, drawingData: "goodbyeworld".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 160, y: 190))
        ]
        let oldPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing(), recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]), stickers: oldStickers, pageText: nil)
        ]

        let draft = try addDraft(named: name, in: store, with: oldPageConfigurations)

        let newName = "Hello Bobby"
        let newStickers = [TestStickerFactory.TestStickerConfiguration(imageData: "jo".data(using: .utf8)!, drawingData: "hihi".data(using: .utf8)!, creationDate: Date(), position: CGPoint(x: 32, y: 38))]
        let allStickers = oldStickers + newStickers

        let newPageConfigurations = [
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: allStickers, pageText: PageText(text: "This is a page", type: .generated, position: CGPoint(x: 1.0, y: 1.0))),
            TestPageFactory.TestPagConfiguration(drawing: PKDrawing.drawingWithStrokes(2),
                                                 recordingURLs: OrderedSet([FileManager.documentsDirectory.appendingPathComponent("x")]),
                                                 stickers: allStickers,
                                                 pageText: PageText(text: "This is another page", type: .modified, position: CGPoint(x: 2.0, y: 2.0)))
        ]

        let newPages = try pageFactory.makeSomePages(configurations: newPageConfigurations)
        await store.updateDraft(named: name, newName: newName, pages: newPages)

        XCTAssertEqual(draft.pages?.count, 2)
        XCTAssertEqual(draft.stickers?.count, 6)

        let pageManagedObjects = try XCTUnwrap(draft.pages as? Set<PageManagedObject>)
        let sortedPageManagedObjects = pageManagedObjects.sorted { $0.number < $1.number }
        zip(sortedPageManagedObjects, newPageConfigurations)
            .forEach {
                XCTAssertEqual($0.0.illustration, $0.1.drawing.dataRepresentation())
                XCTAssertEqual($0.0.audioLastPathComponents as? [String], $0.1.recordingURLs.compactMap { $0?.lastPathComponent })
                XCTAssertNotNil($0.0.text)
                XCTAssertNotNil($0.1.pageText)
                XCTAssertEqual($0.0.text?.text, $0.1.pageText?.text)
                XCTAssertEqual($0.0.text?.type, $0.1.pageText?.type.rawValue)
                XCTAssertEqual($0.0.text?.position, NSCoder.string(for: $0.1.pageText?.position ?? .zero))
            }

        let stickerManagedObjects = try XCTUnwrap(draft.stickers as? Set<StickerManagedObject>)
        let sortedStickerManageObjects = stickerManagedObjects.sorted { $0.creationDate! < $1.creationDate! }
        let actuallyAllTheStickersSorted = (allStickers + allStickers).sorted { $0.creationDate < $1.creationDate }
        zip(sortedStickerManageObjects, actuallyAllTheStickersSorted)
            .forEach {
                XCTAssertEqual($0.0.creationDate, $0.1.creationDate)
                XCTAssertEqual($0.0.drawingData?.count, $0.1.drawingData.count)
                XCTAssertEqual($0.0.position, NSCoder.string(for: $0.1.position))
            }

    }

    func testAddStory() {
        let store = DataStore()
        let url = FileManager.documentsDirectory.appendingPathComponent("story")
        let storyName = "My Story"
        let storyMO = store.addStory(named: storyName,
                                     location: url,
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
                  with pageConfigs: [TestPageFactory.TestPagConfiguration]? = nil) throws -> DraftStoryManagedObject {
        let pages = pageConfigs != nil ? try pageFactory.makeSomePages(configurations: pageConfigs!) : try pageFactory.makeSomePages(number: 2)
        let stickers = pages.map { Array($0.stickers) }.flatMap { $0 }
        let draft = try XCTUnwrap(store.addDraft(named: named, pages: pages, stickers: stickers))

        XCTAssertEqual(draft.pages?.count, pages.count)
        XCTAssertEqual(draft.title, named)
        XCTAssertEqual(draft.stickers?.count, stickers.count)

        let stickerCheck = draft.stickers?
            .compactMap { $0 as? StickerManagedObject }
            .map { smo in
                stickers.filter { sticker in
                    sticker == smo
                }
            }
            .flatMap { $0 }

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

        XCTAssertEqual(pageCheck?.count, pages.count)
        
        draft.pages?
            .compactMap { $0 as? PageManagedObject }
            .forEach {
                XCTAssertEqual($0.text?.page, $0)
                XCTAssertEqual($0.text?.text, pages[Int($0.number)].text?.text)
            }

        return draft
    }
}
