//
//  HierarchySnapshot.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation

struct HierarchySnapshot {

	typealias Model = HierarchyItem

	private(set) var root: [Model] = []

	private(set) var storage: [UUID: [Model]] = [:]

	// MARK: - Initialization

	init(_ base: [ItemEntity]) {
		self.root = base.map { container in
			makeItem(base: container)
		}
	}
}

// MARK: - Public interface
extension HierarchySnapshot {

	func rootItem(at index: Int) -> Model {
		return root[index]
	}

	func numberOfRootItems() -> Int {
		return root.count
	}

	func numberOfChildren(ofItem id: UUID) -> Int {
		guard let children = storage[id] else {
			fatalError()
		}
		return children.count
	}

	func childOfItem(_ id: UUID, at index: Int) -> Model {
		guard let children = storage[id] else {
			fatalError()
		}
		return children[index]
	}
}

// MARK: - Helpers
private extension HierarchySnapshot {

	mutating func makeItem(base: ItemEntity) -> HierarchyItem {
		let item = HierarchyItem(uuid: base.uuid, text: base.content.text, icon: base.content.iconName)
		storage[base.uuid] = base.items?.map { entity in
			makeItem(base: entity)
		}
		return item
	}
}
