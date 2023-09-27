//
//  HierarchyContent.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

struct HierarchyContent {

	private (set) var id: UUID

	private (set) var hierarchy: [Container]

	// MARK: - Initialization

	init(id: UUID, hierarchy: [Container]) {
		self.id = id
		self.hierarchy = hierarchy
	}
}

// MARK: - Codable
extension HierarchyContent: Codable { }

// MARK: - Equatable
extension HierarchyContent: Equatable { }
