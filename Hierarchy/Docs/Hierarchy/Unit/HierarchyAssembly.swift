//
//  HierarchyAssembly.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.10.2023.
//

import Cocoa

final class HierarchyAssembly {

	static func build(storage: DocumentStorage<HierarchyContent>) -> NSViewController {
		let presenter = HierarchyPresenter(storage: storage)
		return HierarchyViewController { viewController in
			viewController.output = presenter
			presenter.view = viewController
		}
	}
}
