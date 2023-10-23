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

		case favorite
		case completed

		case setEstimation

		case setIcon

		case separator
	}
}

extension MenuBuilder.Item {

	func makeItem() -> NSMenuItem {
		switch self {
		case .new:
			let item = NSMenuItem(
				title: "New",
				action: #selector(MenuSupportable.createNew),
				keyEquivalent: "n"
			)
			item.identifier = .init("new")
			return item
		case .delete:
			let item = NSMenuItem(
				title: "Delete",
				action: #selector(MenuSupportable.delete),
				keyEquivalent: "\u{0008}"
			)
			item.identifier = .init("delete")
			return item
		case .separator:
			return .separator()
		case .favorite:
			let item = NSMenuItem(
				title: "Favorite",
				action: #selector(MenuSupportable.toggleBookmark(_:)),
				keyEquivalent: "b"
			)
			item.identifier = .init("favorite")
			return item
		case .completed:
			let item = NSMenuItem(
				title: "Completed",
				action: #selector(MenuSupportable.toggleCompleted(_:)),
				keyEquivalent: "\r"
			)
			item.identifier = .init("completed")
			return item
		case .setEstimation:
			let main = NSMenuItem(
				title: "Set estimation",
				action: #selector(MenuSupportable.toggleCompleted(_:)),
				keyEquivalent: ""
			)
			main.identifier = .init("estimation")
			main.submenu = NSMenu()

			let none = NSMenuItem(
				title: "None",
				action: #selector(MenuSupportable.setEstimation(_:)),
				keyEquivalent: "0"
			)
			none.identifier = .init("estimation_number")
			none.tag = 0
			main.submenu?.addItem(none)

			main.submenu?.addItem(.separator())

			for (index, number) in [1, 2, 3, 5, 8, 13, 21, 34, 55].enumerated() {
				let item = NSMenuItem(
					title: "\(number)",
					action: #selector(MenuSupportable.setEstimation(_:)),
					keyEquivalent: "\(index + 1)"
				)
				item.identifier = .init("estimation_number")
				item.tag = number
				main.submenu?.addItem(item)
			}
			return main
		case .setIcon:
			let main = NSMenuItem(
				title: "Set icon",
				action: #selector(MenuSupportable.toggleCompleted(_:)),
				keyEquivalent: ""
			)
			main.identifier = .init("set_icon")
			main.submenu = NSMenu()

			let none = NSMenuItem(
				title: "None",
				action: #selector(MenuSupportable.setIcon(_:)),
				keyEquivalent: ""
			)
			none.identifier = .init("icon_name")
			main.submenu?.addItem(none)

			main.submenu?.addItem(.separator())

			for category in IconCategory.categories {

				let item = NSMenuItem()
				item.submenu = NSMenu()
				item.title = category.title
				item.identifier = .init("icon_category")

				for icon in category.icons {

					let iconItem = NSMenuItem()
					iconItem.identifier = .init("icon_name")
					iconItem.title = icon
					iconItem.representedObject = icon
					iconItem.action = #selector(MenuSupportable.setIcon(_:))
					iconItem.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)

					item.submenu?.addItem(iconItem)
				}
				main.submenu?.addItem(item)
			}
			return main
		}
	}
}
