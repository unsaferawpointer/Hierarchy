//
//  MenuBuilder+Item.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 01.10.2023.
//

import Cocoa

extension MenuBuilder {

	enum Item {
		case new
		case delete

		case markAsFavorite
		case unmarkAsFavorite

		case markAsCompleted
		case markAsIncomplete

		case separator
	}
}

extension MenuBuilder.Item {

	func makeItem() -> NSMenuItem {
		switch self {
		case .new:
			return NSMenuItem(
				title: "New",
				action: #selector(MenuSupportable.createNew),
				keyEquivalent: "n"
			)
		case .delete:
			return NSMenuItem(
				title: "Delete",
				action: #selector(MenuSupportable.delete),
				keyEquivalent: "\u{0008}"
			)
		case .markAsCompleted:
			return NSMenuItem(
				title: "Mark as completed",
				action: #selector(MenuSupportable.markAsCompleted),
				keyEquivalent: ""
			)
		case .markAsIncomplete:
			return NSMenuItem(
				title: "Mark as incomplete",
				action: #selector(MenuSupportable.markAsIncomplete),
				keyEquivalent: ""
			)
		case .markAsFavorite:
			return NSMenuItem(
				title: "Mark as favorite",
				action: #selector(MenuSupportable.markAsFavorite),
				keyEquivalent: ""
			)
		case .unmarkAsFavorite:
			return NSMenuItem(
				title: "Unmark as favorite",
				action: #selector(MenuSupportable.unmarkAsFavorite),
				keyEquivalent: ""
			)
		case .separator:
			return .separator()
		}
	}
}
