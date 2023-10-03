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

	var options: EntityOptions

	var textDidChange: (String) -> ()

	var statusDidChange: (Bool) -> ()

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		status: Bool,
		text: String,
		icon: String,
		options: EntityOptions,
		textDidChange: @escaping (String) -> (),
		statusDidChange: @escaping (Bool) -> ()
	) {
		self.uuid = uuid
		self.status = status
		self.text = text
		self.icon = icon
		self.options = options
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
