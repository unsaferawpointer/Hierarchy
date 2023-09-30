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

	// MARK: - Initialization

	init(id: UUID, hierarchy: [ItemEntity]) {
		self.id = id
		self.hierarchy = hierarchy
	}
}

// MARK: - Codable
extension HierarchyContent: Codable { }

// MARK: - Equatable
extension HierarchyContent: Equatable {

	static func == (lhs: HierarchyContent, rhs: HierarchyContent) -> Bool {
		return lhs.id == rhs.id && lhs.hierarchy == rhs.hierarchy
	}
}
