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

	func setEstimation(_ value: Int, withSelection selection: [UUID])

	func setIcon(_ value: String?, withSelection selection: [UUID])

	func canUndo() -> Bool

	func canRedo() -> Bool

	func redo()

	func undo()
}

protocol HierarchyView: AnyObject {

	func display(_ snapshot: HierarchySnapshot)

	func setConfiguration(_ configuration: DropConfiguration)

	func scroll(to id: UUID)

	func select(_ id: UUID)

	func expand(_ id: UUID?)

	func focus(on id: UUID)
}

class HierarchyViewController: NSViewController {

	// MARK: - DI

	var adapter: HierarchyTableAdapter?

	var output: HierarchyViewOutput?

	// MARK: - Computed properties

	var selection: [UUID] {
		return table.selectedIdentifiers()
	}

	// MARK: - UI-Properties

	lazy var scrollview = NSScrollView.plain

	lazy var table = NSOutlineView.inset

	lazy var placeholderView = PlaceholderView(frame: .zero)

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
		self.view = NSView()
		configureUserInterface()
		configureConstraints()
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

		placeholderView.isHidden = !snapshot.identifiers.isEmpty
		placeholderView.title = "No Items, yet"
		placeholderView.subtitle = "Add a new element using the plus."
	}

	func setConfiguration(_ configuration: DropConfiguration) {
		adapter?.dropConfiguration = configuration
	}

	func scroll(to id: UUID) {
		adapter?.scroll(to: id)
	}

	func select(_ id: UUID) {
		adapter?.select(id)
	}

	func expand(_ id: UUID?) {
		adapter?.expand(id)
	}

	func focus(on id: UUID) {
		adapter?.focus(on: id)
	}
}

// MARK: - Helpers
private extension HierarchyViewController {

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

	func configureConstraints() {
		[scrollview, placeholderView].forEach {
			view.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate(
			[
				scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollview.topAnchor.constraint(equalTo: view.topAnchor),
				scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),

				placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				placeholderView.topAnchor.constraint(equalTo: view.topAnchor),
				placeholderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
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
					.setEstimation,
					.setIcon,
					.separator,
					.delete
				]
		)
	}
}

// MARK: - NSMenuItemValidation
extension HierarchyViewController: NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		guard let identifier = menuItem.identifier, let adapter else {
			return false
		}

		switch identifier {
		case .redoMenuItem:
			return output?.canRedo() ?? false
		case .undoMenuItem:
			return output?.canUndo() ?? false
		case .newMenuItem,
			 .setEstimationMenuItem,
			 .setIconMenuItem,
			 .iconsGroupMenuItem:
			return true
		default:
			break
		}
		let state = adapter.menuItemState(for: identifier.rawValue)
		menuItem.state = state

		return adapter.validateMenuItem(identifier.rawValue)
	}
}

// MARK: - MenuSupportable
extension HierarchyViewController: MenuSupportable {

	@IBAction
	func createNew(_ sender: NSMenuItem) {
		output?.createNew(with: selection)
	}

	@IBAction
	func delete(_ sender: NSMenuItem) {
		output?.deleteItems(selection)
	}

	@IBAction
	func toggleBookmark(_ sender: NSMenuItem) {
		let enabled = sender.state == .on
		output?.setBookmark(!enabled, withSelection: selection)
	}

	@IBAction
	func toggleCompleted(_ sender: NSMenuItem) {
		let enabled = sender.state == .on
		output?.setState(!enabled, withSelection: selection)
	}

	@IBAction
	func setEstimation(_ sender: NSMenuItem) {
		let number = sender.tag
		output?.setEstimation(number, withSelection: selection)
	}

	@IBAction
	func setIcon(_ sender: NSMenuItem) {
		let iconName = sender.representedObject as? String
		output?.setIcon(iconName, withSelection: selection)
	}

	@IBAction
	func undo(_ sender: NSMenuItem) {
		output?.undo()
	}

	@IBAction
	func redo(_ sender: NSMenuItem) {
		output?.redo()
	}
}
