//
//  HierarchySnapshot.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation

struct HierarchySnapshot {

	typealias Model = HierarchyModel

	private(set) var root: [Model] = []

	private(set) var storage: [UUID: [Model]] = [:]

	private(set) var cache: [UUID: Model] = [:]

	private(set) var identifiers: Set<UUID> = .init()

	// MARK: - Initialization

	init(_ base: [ItemEntity], transform: (ItemEntity) -> HierarchyModel) {
		self.root = base.map { container in
			makeItem(base: container, transform: transform)
		}
	}

	/// Initialize empty snapshot
	init() { }
}

// MARK: - Public interface
extension HierarchySnapshot {

	func rootItem(at index: Int) -> Model {
		return root[index]
	}

	func rootIdentifier(at index: Int) -> UUID {
		return root[index].id
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

	func model(with id: UUID) -> Model {
		return cache[unsafe: id]
	}
}

// MARK: - Helpers
private extension HierarchySnapshot {

	mutating func makeItem(base: ItemEntity, transform: (ItemEntity) -> HierarchyModel) -> HierarchyModel {

		let item = transform(base)

		// Store in cache
		identifiers.insert(item.id)
		cache[item.id] = item

		storage[base.uuid] = base.items.map { entity in
			makeItem(base: entity, transform: transform)
		}
		return item
	}
}
