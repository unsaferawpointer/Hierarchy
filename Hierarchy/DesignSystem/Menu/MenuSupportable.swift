//
//  MenuSupportable.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 01.10.2023.
//

import Cocoa

@objc
protocol MenuSupportable {

	@objc
	optional func createNew(_ sender: NSMenuItem)

	@objc
	optional func delete(_ sender: NSMenuItem)

	@objc
	optional func markAsFavorite(_ sender: NSMenuItem)

	@objc
	optional func unmarkAsFavorite(_ sender: NSMenuItem)

	@objc
	optional func markAsCompleted(_ sender: NSMenuItem)

	@objc
	optional func markAsIncomplete(_ sender: NSMenuItem)

	@objc
	optional func fold(_ sender: NSMenuItem)

	@objc
	optional func unfold(_ sender: NSMenuItem)

}
