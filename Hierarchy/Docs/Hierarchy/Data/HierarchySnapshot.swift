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

	init(_ base: [Container]) {
		self.root = base.map { container in
			makeItem(container)
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

	mutating func makeItem(_ base: Container) -> HierarchyItem {
		switch base {
		case .list(let uuid, let icon, let text, let todos):
			let item = HierarchyItem(uuid: uuid, text: text, icon: icon)
			storage[uuid] = todos.map { todo in
				makeItem(todo)
			}
			return item
		case .section(let uuid, let icon, let text, let items):
			let item = HierarchyItem(uuid: uuid, text: text, icon: icon)
			storage[uuid] = items.map { container in
				makeItem(container)
			}
			return item
		}
	}

	func makeItem(_ base: Todo) -> HierarchyItem {
		return .init(uuid: base.uuid, text: base.text, icon: "app")
	}
}
