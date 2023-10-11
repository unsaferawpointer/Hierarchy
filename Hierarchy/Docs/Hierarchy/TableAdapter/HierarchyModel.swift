//
//  HierarchyModel.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation

struct HierarchyModel {

	var uuid: UUID

	var status: Bool

	var text: String

	var icon: String

	var style: Style

	var isFavorite: Bool

	var textDidChange: (String) -> ()

	var statusDidChange: (Bool) -> ()

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		status: Bool,
		text: String,
		icon: String,
		style: Style = .checkbox,
		isFavorite: Bool,
		textDidChange: @escaping (String) -> (),
		statusDidChange: @escaping (Bool) -> ()
	) {
		self.uuid = uuid
		self.status = status
		self.text = text
		self.icon = icon
		self.style = style
		self.isFavorite = isFavorite
		self.textDidChange = textDidChange
		self.statusDidChange = statusDidChange
	}
}

// MARK: - Identifiable
extension HierarchyModel: Identifiable {

	var id: UUID {
		return uuid
	}
}

// MARK: - Hashable
extension HierarchyModel: Hashable {

	static func == (lhs: HierarchyModel, rhs: HierarchyModel) -> Bool {
		return lhs.uuid == rhs.uuid
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
}

extension HierarchyModel {

	enum Style: Equatable {
		case checkbox
		case list
		case icon(_ name: String)
	}
}
