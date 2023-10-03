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
	optional func createNew()

	@objc
	optional func delete()

	@objc
	optional func showCheckbox()

	@objc
	optional func hideCheckbox()

	@objc
	optional func markAsCompleted()

	@objc
	optional func markAsIncomplete()

}
