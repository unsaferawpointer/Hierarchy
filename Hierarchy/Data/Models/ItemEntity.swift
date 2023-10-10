//
//  ItemEntity.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Foundation

final class ItemEntity {

	var uuid: UUID

	var content: ItemContent

	var options: EntityOptions

	var items: [ItemEntity]

	// MARK: - Transient properties

	weak var parent: ItemEntity?

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		content: ItemContent,
		options: EntityOptions = [],
		items: [ItemEntity] = []
	) {
		self.uuid = uuid
		self.content = content
		self.options = options
		self.items = items
		items.forEach { item in
			item.parent = self
		}
	}
}

// MARK: - Equatable
extension ItemEntity: Equatable {

	static func == (lhs: ItemEntity, rhs: ItemEntity) -> Bool {
		return lhs.uuid == rhs.uuid
		&& lhs.content == rhs.content
		&& lhs.options == rhs.options
		&& lhs.items == rhs.items
	}
}

// MARK: - Hashable
extension ItemEntity: Hashable {

	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
		hasher.combine(content)
		hasher.combine(options)
		hasher.combine(items)
	}
}

// MARK: - Codable
extension ItemEntity: Codable { 

	enum CodingKeys: CodingKey {
		case uuid
		case content
		case options
		case items
	}

	convenience init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let uuid = try container.decode(UUID.self, forKey: .uuid)
		let content = try container.decode(ItemContent.self, forKey: .content)
		let options = try container.decode(EntityOptions.self, forKey: .options)
		let items = try container.decodeIfPresent([ItemEntity].self, forKey: .items) ?? []
		self.init(uuid: uuid, content: content, options: options, items: items)
	}
}

// MARK: - Calculated properties
extension ItemEntity {

	var effectiveStatus: Bool {
		guard !items.isEmpty else {
			return content.isDone
		}
		return items.allSatisfy { entity in
			return entity.effectiveStatus
		}
	}
}

// MARK: - Public interface
extension ItemEntity {

	func insertItems(with items: [ItemEntity], to index: Int) {
		self.items.insert(contentsOf: items, at: index)
		items.forEach { item in
			item.parent = self
		}
	}

	func appendItems(with items: [ItemEntity]) {
		self.items.append(contentsOf: items)
		items.forEach { item in
			item.parent = self
		}
	}

	@discardableResult
	func deleteChild(_ id: UUID) -> Int? {
		guard let index = items.firstIndex(where: \.uuid, equalsTo: id) else {
			return nil
		}
		items.remove(at: index)
		return index
	}

	func setProperty<T>(_ keyPath: ReferenceWritableKeyPath<ItemEntity, T>, to value: T, downstream: Bool) {
		self[keyPath: keyPath] = value
		if downstream {
			items.forEach { item in
				item.setProperty(
					keyPath,
					to: value,
					downstream: downstream
				)
			}
		}
	}

}

// MARK: - Helpers
extension ItemEntity {

	func enumerateBackwards(_ block: (ItemEntity) -> Void) {
		block(self)
		parent?.enumerateBackwards(block)
	}

	func enumerate(_ block: (ItemEntity) -> Void) {
		block(self)
		for item in items {
			item.enumerate(block)
		}
	}
}
