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

	var items: [ItemEntity]?

	init(
		uuid: UUID = UUID(),
		content: ItemContent,
		options: EntityOptions = [],
		items: [ItemEntity]? = nil
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
extension ItemEntity: Codable { }
