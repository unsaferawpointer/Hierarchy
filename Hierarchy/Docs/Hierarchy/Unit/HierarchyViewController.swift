//
//  HierarchyViewController.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Cocoa

class HierarchyViewController: NSViewController {

	var adapter: HierarchyTableAdapter?

	// MARK: - UI-Properties

	lazy var scrollview = NSScrollView.plain

	lazy var table = NSOutlineView.inset

	// MARK: - Initialization

	init(storage: DocumentStorage<HierarchyContent>) {
		super.init(nibName: nil, bundle: nil)
		self.adapter = HierarchyTableAdapter(table: table, storage: storage)
	}
	
	@available(*, unavailable, message: "Use init(storage:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View life-cycle

	override func loadView() {
		self.view = scrollview
		configureUserInterface()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		table.sizeLastColumnToFit()
	}
}

// MARK: - Helpers
extension HierarchyViewController {

	func configureUserInterface() {

		table.headerView = nil
		table.autoresizesOutlineColumn = false

		scrollview.documentView = table

		let identifier = NSUserInterfaceItemIdentifier("main")
		let column = NSTableColumn(identifier: identifier)
		table.addTableColumn(column)
	}
}
