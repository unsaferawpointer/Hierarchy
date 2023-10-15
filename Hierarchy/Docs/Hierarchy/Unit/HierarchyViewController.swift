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

	func setState(_ flag: Bool, withSelection selection: [UUID])

	func setBookmark(_ flag: Bool, withSelection selection: [UUID])
}

protocol HierarchyView: AnyObject {

	func display(_ snapshot: HierarchySnapshot)

	func setConfiguration(_ configuration: DropConfiguration)
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

	func setConfiguration(_ configuration: DropConfiguration) {
		adapter?.dropConfiguration = configuration
	}
}

// MARK: - Helpers
extension HierarchyViewController {

	func configureUserInterface() {

		table.headerView = nil
		table.autoresizesOutlineColumn = false
		table.allowsMultipleSelection = true

		scrollview.documentView = table
		scrollview.hasVerticalScroller = false

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
					.favorite,
					.completed,
					.separator,
					.delete
				]
		)
	}
}

// MARK: - NSMenuItemValidation
extension HierarchyViewController: NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		guard let identifier = menuItem.identifier?.rawValue, let adapter else {
			return false
		}

		switch identifier {
		case "new":
			return true
		default:
			break
		}
		let state = adapter.menuItemState(for: identifier)
		menuItem.state = state

		return adapter.validateMenuItem(identifier)
	}
}

// MARK: - MenuSupportable
extension HierarchyViewController: MenuSupportable {

	@IBAction
	func createNew(_ sender: NSMenuItem) {
		let selection = table.selectedIdentifiers()
		output?.createNew(with: selection)
	}

	@IBAction
	func delete(_ sender: NSMenuItem) {
		let selection = table.selectedIdentifiers()
		output?.deleteItems(selection)
	}

	@IBAction
	func toggleBookmark(_ sender: NSMenuItem) {
		let enabled = sender.state == .on
		let selection = table.selectedIdentifiers()
		output?.setBookmark(!enabled, withSelection: selection)
	}

	@IBAction
	func toggleCompleted(_ sender: NSMenuItem) {
		let enabled = sender.state == .on
		let selection = table.selectedIdentifiers()
		output?.setState(!enabled, withSelection: selection)
	}

	@IBAction
	func fold(_ sender: NSMenuItem) {
		// TODO: Handle action
	}

	@IBAction
	func unfold(_ sender: NSMenuItem) {
		// TODO: Handle action
	}
}
