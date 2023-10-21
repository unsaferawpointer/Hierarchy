//
//  HierarchyContent.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

final class HierarchyContent {

	private (set) var id: UUID

	private (set) var hierarchy: [ItemEntity]

	// MARK: - Cache

	private (set) var cache: [UUID: ItemEntity] = [:]

	// MARK: - Initialization

	init(id: UUID, hierarchy: [ItemEntity]) {
		self.id = id
		self.hierarchy = hierarchy
		hierarchy.forEach { item in
			item.enumerate {
				cache[$0.uuid] = $0
			}
		}
	}
}

// MARK: - Codable
extension HierarchyContent: Codable {

	enum CodingKeys: CodingKey {
		case id
		case hierarchy
	}

	convenience init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let id = try container.decode(UUID.self, forKey: .id)
		let hierarchy = try container.decode([ItemEntity].self, forKey: .hierarchy)
		self.init(id: id, hierarchy: hierarchy)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(hierarchy, forKey: .hierarchy)
	}
}

// MARK: - Equatable
extension HierarchyContent: Equatable {

	static func == (lhs: HierarchyContent, rhs: HierarchyContent) -> Bool {
		return lhs.id == rhs.id && lhs.hierarchy == rhs.hierarchy
	}
}

// MARK: - Configure properties
extension HierarchyContent {

	func setText(_ value: String, for id: UUID) {
		guard let item = cache[id] else {
			return
		}
		item.setProperty(\.content.text, to: value, downstream: false)
	}

	func setStatus(_ value: Bool, for ids: [UUID]) {
		for id in ids {
			guard let item = cache[id] else {
				continue
			}
			item.setProperty(
				\.content.isDone,
				 to: value,
				 downstream: true
			)
		}
	}

	func setFavoriteFlag(_ flag: Bool, for ids: [UUID]) {
		for id in ids {
			guard let item = cache[id] else {
				continue
			}
			item.setProperty(\.isFavorite, to: flag, downstream: false)
		}
	}

	func setEstimation(_ value: Int, for ids: [UUID]) {
		for id in ids {
			guard let item = cache[id] else {
				continue
			}
			item.setProperty(\.content.value, to: value, downstream: false)
		}
	}

}

// MARK: - Public interface
extension HierarchyContent {

	func insertItems(with contents: [ItemContent], with id: UUID, to destination: HierarchyDestination) {
		let items = contents.map { ItemEntity(uuid: id, content: $0) }
		switch destination {
		case .toRoot:
			hierarchy.append(contentsOf: items)
		case let .inRoot(index):
			hierarchy.insert(contentsOf: items, at: index)
		case let .onItem(id):
			guard let item = cache[id] else {
				return
			}
			item.appendItems(with: items)
		case let .inItem(id, index):
			guard let item = cache[id] else {
				return
			}
			item.insertItems(with: items, to: index)
		}
		items.forEach { item in
			cache[item.uuid] = item
		}
	}

	func deleteItems(_ ids: [UUID]) {
		for id in ids {
			deleteItem(id)
		}
	}

	func validateMoving(_ ids: [UUID], to destination: HierarchyDestination) -> Bool {
		guard let targetId = destination.id, let item = cache[targetId] else {
			return true
		}

		var chain = Set<UUID>()
		item.enumerateBackwards {
			chain.insert($0.uuid)
		}

		let intersection = chain.intersection(ids)

		return intersection.isEmpty
	}

	func moveItems(with ids: [UUID], to destination: HierarchyDestination) {
		let moved = ids.compactMap {
			cache[$0]
		}

		switch destination {
		case .toRoot:
			move(moved, to: nil)
		case let .inRoot(index):
			moveToRoot(moved, at: index)
		case let .onItem(id):
			guard let target = cache[id] else {
				return
			}
			move(moved, to: target)
		case let .inItem(id, index):
			guard let target = cache[id] else {
				return
			}
			move(moved, toOther: target, at: index)
		}
	}
}

// MARK: - Support moving
private extension HierarchyContent {

	func moveToRoot(_ moved: [ItemEntity], at index: Int) {

		let grouped = Dictionary<ItemEntity?, [ItemEntity]>(grouping: moved) { item in
			return item.parent
		}

		var offset = 0

		for (container, items) in grouped {

			let cache = Set(items.map(\.uuid))

			guard let container else {

				offset = self.offset(
					moved: cache,
					in: hierarchy,
					to: index
				)

				hierarchy.removeAll { item in
					cache.contains(item.uuid)
				}
				continue
			}

			container.items.removeAll { item in
				cache.contains(item.uuid)
			}

		}

		hierarchy.insert(contentsOf: moved, at: index + offset)
		moved.forEach { item in
			item.parent = nil
		}
	}

	func move(_ moved: [ItemEntity], toOther target: ItemEntity, at index: Int) {

		let grouped = Dictionary<ItemEntity?, [ItemEntity]>(grouping: moved) { item in
			return item.parent
		}

		var offset = 0

		for (container, items) in grouped {
			let cache = Set(items.map(\.uuid))

			guard let container else {
				hierarchy.removeAll { item in
					cache.contains(item.uuid)
				}
				continue
			}

			if container.uuid == target.uuid {
				offset = self.offset(
					moved: cache,
					in: container.items,
					to: index
				)
			}
			container.items.removeAll { item in
				cache.contains(item.uuid)
			}
		}

		target.insertItems(with: moved, to: index + offset)
	}

	func move(_ moved: [ItemEntity], to target: ItemEntity?) {

		let grouped = Dictionary<ItemEntity?, [ItemEntity]>(grouping: moved) { item in
			return item.parent
		}

		for (container, items) in grouped {

			let cache = Set(items.map(\.uuid))

			guard let container else {
				hierarchy.removeAll { item in
					cache.contains(item.uuid)
				}
				continue
			}

			container.items.removeAll { item in
				cache.contains(item.uuid)
			}
		}

		guard let target else {
			hierarchy.append(contentsOf: moved)
			moved.forEach { item in
				item.parent = nil
			}
			return
		}

		target.appendItems(with: moved)
	}

	func offset(moved: Set<UUID>, in items: [ItemEntity], to index: Int) -> Int {
		var indexes = [Int]()
		for id in moved {
			guard let firstIndex = items.firstIndex(where: \.uuid, equalsTo: id) else {
				continue
			}
			indexes.append(firstIndex)
		}
		return -indexes.filter { $0 < index }.count
	}
}

// MARK: - Deleting
private extension HierarchyContent {

	func deleteItem(_ id: UUID) {
		guard let item = cache[id] else {
			return
		}
		guard let parent = item.parent else {
			if let index = hierarchy.firstIndex(where: \.uuid, equalsTo: id) {
				hierarchy.remove(at: index)
			}
			return
		}
		parent.deleteChild(id)
		cache[id] = nil
	}
}
