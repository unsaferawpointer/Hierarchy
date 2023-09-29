//
//  HierarchyItem.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation

struct HierarchyItem {

	var uuid: UUID

	var text: String

	var icon: String

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		text: String,
		icon: String
	) {
		self.uuid = uuid
		self.text = text
		self.icon = icon
	}
}

// MARK: - Equatable
extension HierarchyItem: Equatable { }
