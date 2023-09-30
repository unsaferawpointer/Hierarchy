//
//  HierarchyDocument.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Cocoa

class HierarchyDocument: NSDocument {

	var storage: DocumentStorage<HierarchyContent>

	override init() {
		self.storage = DocumentStorage<HierarchyContent>(
			initialState: .init(id: .init(), hierarchy: []),
			provider: HierarchyDataProvider()
		)
		super.init()
		storage.addObservation(for: self) { [weak self] _, content in
			self?.updateChangeCount(.changeDone)
		}
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(
			withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")
		) as! NSWindowController
		windowController.window?.contentViewController = HierarchyViewController(storage: storage)
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		return try storage.data(ofType: typeName)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		try storage.read(from: data, ofType: typeName)
	}

}
