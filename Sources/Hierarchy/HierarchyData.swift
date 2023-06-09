//
//  HierarchyData.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 07.05.2023.
//

import Foundation

/// Hierarchy data representation
public final class HierarchyData<Item: ReferenceIdentifiable> {

	private (set) var root: [ObjectIdentifier] = []

	private (set) var storage: [ObjectIdentifier: Item] = [:]

	private (set) var hierarchy: [ObjectIdentifier: [ObjectIdentifier]] = [:]

	private (set) var parents: [ObjectIdentifier: ObjectIdentifier] = [:]

	private (set) var oldSnapshot: Snapshot?

	public init() { }
}

public extension HierarchyData {

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

	func item(for id: ObjectIdentifier) -> Item? {
		return storage[id]
	}

	func isDescendant(_ itemId: ObjectIdentifier, of otherId: ObjectIdentifier) -> Bool {
		guard let parentId = parents[itemId] else {
			return false
		}
		return parentId == otherId ? true : isDescendant(parentId, of: otherId)
	}

	/// Returns children of item
	///
	/// - Parameters:
	///    - parent: Parent item
	/// - Warning: If there is no item in the store, causes a fatal error
	func children(of parent: Item?) -> [Item] {
		guard let parent else {
			return root.map { storage[unsafe: $0] }
		}
		let children = hierarchy[unsafe: parent.id]
		return children.map { storage[unsafe: $0] }
	}

	/// Returns level of the item
	func getLevel(of item: Item) -> Int {
		var parent = parents[item.id]
		var result = 0
		while parent != nil {
			parent = parents[parent!]
			result += 1
		}
		return result
	}

	/// Clear all data
	func clearStorage() {
		root = []
		storage = [:]
		hierarchy = [:]
		parents = [:]
	}
}

// MARK: - Insert items
public extension HierarchyData {

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
public extension HierarchyData {

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

// MARK: - Move items
public extension HierarchyData {

	/// Move items to target
	///
	/// - Parameters:
	///    - items: Moving items
	///    - target: Target of the moving.
	/// - Note: If target is `nil`, appends to root items
	func move(_ items: [Item], to target: Item?) {
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

		parents.removeValues(forKeys: ids)

		if let targetId = target?.id {
			var children = hierarchy[unsafe: targetId]
			children.append(contentsOf: ids)
			hierarchy[targetId] = children
			ids.forEach { parents[$0] = targetId }
		} else {
			root.append(contentsOf: ids)
		}

	}

	/// Move items to target
	///
	/// - Parameters:
	///    - items: Moving items
	///    - target: Target of the moving.
	///    - index: Index of the insertion
	func move(_ items: [Item], to target: Item, at index: Int) {
		let ids = items.map(\.id)

		let grouped = Dictionary(grouping: ids) { id -> ObjectIdentifier? in
			return parents[id]
		}

		var targetIndex = index

		for (parentId, ids) in grouped {
			guard let parentId else {
				root.removeAll { ids.contains($0) }
				continue
			}

			var children = hierarchy[unsafe: parentId]

			let cache = Set(ids)

			if parentId == target.id {
				let indexes = children.enumerated().compactMap {
					return cache.contains($0.element) ? $0.offset : nil
				}
				let shift = indexes.filter { $0 < targetIndex }.count
				targetIndex -= shift
			}
			children.removeAll { ids.contains($0) }

			hierarchy[parentId] = children
		}

		parents.removeValues(forKeys: ids)

		var children = hierarchy[unsafe: target.id]
		children.insert(contentsOf: ids, at: targetIndex)
		hierarchy[target.id] = children
		ids.forEach { parents[$0] = target.id }
	}

	/// Move items to root at specific index
	///
	/// - Parameters:
	///    - items: Moving items
	///    - index: Index of the insertion
	func moveToRoot(_ items: [Item], at index: Int) {
		let ids = items.map(\.id)

		let grouped = Dictionary(grouping: ids) { id -> ObjectIdentifier? in
			return parents[id]
		}

		var targetIndex = index

		for (parentId, ids) in grouped {
			guard let parentId else {
				let cache = Set(ids)
				let indexes = root.enumerated().compactMap {
					return cache.contains($0.element) ? $0.offset : nil
				}
				let shift = indexes.filter { $0 < targetIndex }.count
				targetIndex -= shift
				root.removeAll { ids.contains($0) }
				continue
			}

			var children = hierarchy[unsafe: parentId]
			children.removeAll { ids.contains($0) }

			hierarchy[parentId] = children
		}

		parents.removeValues(forKeys: ids)

		root.insert(contentsOf: ids, at: targetIndex)
		ids.forEach { parents[$0] = nil }
	}

	/// Returns ability to move items to specific target
	func canMove(_ items: [Item], to target: Item?) -> Bool {
		guard let target else {
			return true
		}
		return items.map(\.id).allSatisfy { !isDescendant(target.id, of: $0) && target.id != $0 }
	}
}

// MARK: - Diffing
public extension HierarchyData {

	func startUpdating() {
		self.oldSnapshot = Snapshot(root: root, storage: storage, hierarchy: hierarchy)
	}

	func endUpdating() -> [HierarchyDiffAction<Item>] {
		defer {
			oldSnapshot = nil
		}
		guard let oldSnapshot else {
			assertionFailure("Please, start updating before")
			return []
		}
		let newSnapshot = Snapshot(root: root, storage: storage, hierarchy: hierarchy)
		return newSnapshot.diff(from: oldSnapshot)
	}
}
