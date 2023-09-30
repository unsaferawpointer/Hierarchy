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

	var items: [ItemEntity]?
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
