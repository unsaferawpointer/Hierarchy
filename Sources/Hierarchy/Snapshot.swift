//
//  Snapshot.swift
//  
//
//  Created by Anton Cherkasov on 08.05.2023.
//

import Foundation

extension HierarchyData {

	struct Snapshot {

		private (set) var root: [ObjectIdentifier] = []

		private (set) var storage: [ObjectIdentifier: Item] = [:]

		private (set) var hierarchy: [ObjectIdentifier: [ObjectIdentifier]] = [:]
	}
}

extension HierarchyData.Snapshot {

	typealias Snapshot = HierarchyData.Snapshot

	typealias Action = HierarchyDiffAction<Item>

	func diff(from other: Snapshot) -> [Action] {
		var result: [Action] = []
		calculate(other: other, in: nil) { animation in
			result.append(animation)
		}
		return result
	}
}

// MARK: - Helpers
private extension HierarchyData.Snapshot {

	func children(for parentId: ObjectIdentifier?) -> [ObjectIdentifier] {
		guard let parentId else {
			return root
		}
		return hierarchy[unsafe: parentId]
	}

	func calculate(other: Snapshot, in parent: ObjectIdentifier?, callback: (Action) -> Void) {

		var oldBuffer = other.children(for: parent)
		let newBuffer = children(for: parent)

		guard !oldBuffer.isEmpty || !newBuffer.isEmpty else {
			return
		}

		let difference = newBuffer.difference(from: oldBuffer)

		if !difference.isEmpty {
			let item = other.storage[optional: parent]
			callback(.updateItem(item))
		}

		for change in difference {
			switch change {
				case .remove(let offset, _, _):
					oldBuffer.remove(at: offset)
					let indexes = IndexSet(integer: offset)
					let item = other.storage[optional: parent]
					callback(.removeItems(atIndexes: indexes, inParent: item))
				case .insert(let offset, _, _):
					let indexes = IndexSet(integer: offset)
					let item = other.storage[optional: parent]
					callback(.insertItems(atIndexes: indexes, inParent: item))
			}
		}

		oldBuffer.forEach {
			calculate(other: other, in: $0, callback: callback)
		}
	}
}
