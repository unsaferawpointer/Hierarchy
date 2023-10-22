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

	var style: Style

	var isFavorite: Bool

	var number: Int

	var menu: MenuItem

	var textDidChange: (String) -> ()

	var statusDidChange: (Bool) -> ()

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		status: Bool,
		text: String,
		style: Style = .checkbox,
		isFavorite: Bool,
		number: Int,
		menu: MenuItem,
		textDidChange: @escaping (String) -> (),
		statusDidChange: @escaping (Bool) -> ()
	) {
		self.uuid = uuid
		self.status = status
		self.text = text
		self.style = style
		self.isFavorite = isFavorite
		self.number = number
		self.menu = menu
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
