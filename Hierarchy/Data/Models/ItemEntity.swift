//
//  ItemEntity.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Foundation

struct ItemEntity {

	var uuid: UUID

	var content: ItemContent

	var options: EntityOptions

	private (set) var items: [ItemEntity]

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

// MARK: - Codable
extension ItemEntity: Codable { 

	enum CodingKeys: CodingKey {
		case uuid
		case content
		case options
		case items
	}

	init(from decoder: Decoder) throws {
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

	var numberOfChildren: Int {
		return items.count
	}

	func child(at index: Int) -> ItemEntity {
		return items[index]
	}

	mutating func setStatus(_ value: Bool, for id: UUID, downstream: Bool) {
		guard uuid == id || downstream else {
			for index in items.indices {
				items[index].setStatus(value, for: id, downstream: false)
			}
			return
		}
		content.isDone = value
		for index in items.indices {
			items[index].setStatus(value, for: id, downstream: true)
		}
	}

	mutating func setText(_ value: String, for id: UUID) {
		guard id == self.uuid else {
			for index in items.indices {
				items[index].setText(value, for: id)
			}
			return
		}
		content.text = value
	}

	mutating func deleteItems(_ ids: Set<UUID>) {
		for index in items.indices {
			items[index].deleteItems(ids)
		}
		items.removeAll { entity in
			ids.contains(entity.uuid)
		}
	}

	mutating func appendItems(_ inserted: [ItemEntity], to id: UUID) {
		guard id == self.uuid else {
			for index in items.indices {
				items[index].appendItems(inserted, to: id)
			}
			return
		}
		items.append(contentsOf: inserted)
	}
}
