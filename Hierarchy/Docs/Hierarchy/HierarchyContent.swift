//
//  HierarchyContent.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2023.
//

import Foundation

struct HierarchyContent {

	private (set) var id: UUID

	private (set) var hierarchy: [ItemEntity]

	// MARK: - Initialization

	init(id: UUID, hierarchy: [ItemEntity]) {
		self.id = id
		self.hierarchy = hierarchy
	}
}

// MARK: - Codable
extension HierarchyContent: Codable {

	enum CodingKeys: CodingKey {
		case id
		case hierarchy
	}

	init(from decoder: Decoder) throws {
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

// MARK: - Public interface
extension HierarchyContent {

	mutating func deleteItems(with ids: Set<UUID>) {
		hierarchy.removeAll { item in
			ids.contains(item.uuid)
		}
		for index in hierarchy.indices {
			hierarchy[index].deleteItems(ids)
		}
	}

	mutating func appendItems(with contents: [ItemContent], to target: UUID?) {
		let items = contents.map { content in
			ItemEntity(content: content)
		}
		guard let target else {
			hierarchy.append(contentsOf: items)
			return
		}
		for index in hierarchy.indices {
			hierarchy[index].appendItems(items, to: target)
		}
	}

	mutating func setStatus(_ value: Bool, for id: UUID) {
		for index in hierarchy.indices {
			hierarchy[index].setStatus(value, for: id, downstream: false)
		}
	}

	mutating func setText(_ value: String, for id: UUID) {
		for index in hierarchy.indices {
			hierarchy[index].setText(value, for: id)
		}
	}
}
