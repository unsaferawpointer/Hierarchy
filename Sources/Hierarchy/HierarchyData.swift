//
//  HierarchyData.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 07.05.2023.
//

import Foundation

/// Hierarchy data representation
final class HierarchyData<Item: ReferenceIdentifiable> {

	private (set) var root: [ObjectIdentifier] = []

	private (set) var storage: [ObjectIdentifier: Item] = [:]

	private (set) var hierarchy: [ObjectIdentifier: [ObjectIdentifier]] = [:]

	private (set) var parents: [ObjectIdentifier: ObjectIdentifier] = [:]
}

extension HierarchyData {

	func numberOfChildren(of item: Item?) -> Int {
		guard let item else {
			return root.count
		}
		return hierarchy[unsafe: item.id].count
	}

	func child(in parent: Item?, at index: Int) -> Item {
		guard let item = parent else {
			let id = root[index]
			return storage[unsafe: id]
		}
		let id = hierarchy[unsafe: item.id][index]
		return storage[unsafe: id]
	}
}

// MARK: - Operations
extension HierarchyData {

	/// Insert items to root
	///
	/// - Parameters:
	///    - items: Inserting items
	///    - index: Index of the insertion
	/// - Note: If index is `nil`, append to root elements
	/// - Complexity: O(1)
	func insert(_ items: [Item], at index: Int?) {

		let ids = items.map(\.id)

		if let index {
			root.insert(contentsOf: ids, at: index)
		} else {
			root.append(contentsOf: ids)
		}

		items.forEach {
			storage[$0.id] = $0
			hierarchy[$0.id] = []
			parents[$0.id] = nil
		}
	}

	/// Insert items to target
	///
	/// - Parameters:
	///    - items: Insering items
	///    - target: Destination of the insertion
	///    - index: Index of the insertion
	/// - Note: If index is `nil`, appends to target children
	/// - Complexity: O(1)
	func insert(_ items: [Item], to target: Item, at index: Int?) {

		let ids = items.map(\.id)

		var children = hierarchy[unsafe: target.id]

		if let index {
			children.insert(contentsOf: ids, at: index)
		} else {
			children.append(contentsOf: ids)
		}

		hierarchy[target.id] = children

		items.forEach {
			storage[$0.id] = $0
			hierarchy[$0.id] = []
			parents[$0.id] = target.id
		}
	}
}

// MARK: - Remove items
extension HierarchyData {

	/// Remove items
	///
	/// - Parameters:
	///    - items: Removing items
	func remove(_ items: [Item]) {

		let ids = items.map(\.id)

		let grouped = Dictionary(grouping: ids) { id -> ObjectIdentifier? in
			return parents[id]
		}

		for (parentId, ids) in grouped {
			guard let parentId else {
				root.removeAll { ids.contains($0) }
				continue
			}

			var children = hierarchy[unsafe: parentId]
			children.removeAll { ids.contains($0) }
			hierarchy[parentId] = children
		}

		ids.forEach { remove($0) }
	}

	/// Recursive removing item
	private func remove(_ id: ObjectIdentifier) {
		let children = hierarchy[unsafe: id]

		hierarchy.removeValue(forKey: id)
		storage.removeValue(forKey: id)
		parents.removeValue(forKey: id)

		for child in children {
			remove(child)
		}
	}
}
