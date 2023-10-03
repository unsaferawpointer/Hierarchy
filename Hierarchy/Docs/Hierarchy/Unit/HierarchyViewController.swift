//
//  HierarchyViewController.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Cocoa

protocol HierarchyViewOutput {

	func viewDidLoad()

	func deleteItems(_ ids: [UUID])
	func createNew(with selection: [UUID])

}

protocol HierarchyView: AnyObject {
	func display(_ snapshot: HierarchySnapshot)
}

class HierarchyViewController: NSViewController {

	var adapter: HierarchyTableAdapter?

	var output: HierarchyViewOutput?

	// MARK: - UI-Properties

	lazy var scrollview = NSScrollView.plain

	lazy var table = NSOutlineView.inset

	// MARK: - Initialization

	init(configure: (HierarchyViewController) -> Void) {
		super.init(nibName: nil, bundle: nil)
		configure(self)
		self.adapter = HierarchyTableAdapter(table: table)
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
		output?.viewDidLoad()
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		table.sizeLastColumnToFit()
	}
}

// MARK: - HierarchyView
extension HierarchyViewController: HierarchyView {

	func display(_ snapshot: HierarchySnapshot) {
		adapter?.apply(snapshot)
	}
}

// MARK: - Helpers
extension HierarchyViewController {

	func configureUserInterface() {

		table.headerView = nil
		table.autoresizesOutlineColumn = false
		table.allowsMultipleSelection = true

		scrollview.documentView = table

		let identifier = NSUserInterfaceItemIdentifier("main")
		let column = NSTableColumn(identifier: identifier)
		table.addTableColumn(column)

		table.menu = makeContextMenu()
	}

	func makeContextMenu() -> NSMenu {
		return MenuBuilder.makeMenu(
			withTitle: "Context", 
			for: 
				[
					.new,
					.separator,
					.markAsCompleted,
					.markAsIncomplete,
					.separator,
					.showCheckbox,
					.hideCheckbox,
					.separator,
					.delete
				]
		)
	}
}

// MARK: - MenuSupportable
extension HierarchyViewController: MenuSupportable {

	func createNew() {
		let selection = table.selectedIdentifiers()
		output?.createNew(with: selection)
	}

	func delete() {
		let selection = table.selectedIdentifiers()
		output?.deleteItems(selection)
	}

	func showCheckbox() {
		// TODO: - Handle action
	}

	func hideCheckbox() {
		// TODO: - Handle action
	}

	func markAsCompleted() {
		// TODO: - Handle action
	}

	func markAsIncomplete() {
		// TODO: - Handle action
	}
}
