//
//  NSScrollView+Extension.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Cocoa

extension NSScrollView {

	static var plain: NSScrollView {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = true
		view.automaticallyAdjustsContentInsets = true
		view.additionalSafeAreaInsets = NSEdgeInsets(
			top: 0, left: 24, bottom: 24, right: 24
		)
		return view
	}
}
