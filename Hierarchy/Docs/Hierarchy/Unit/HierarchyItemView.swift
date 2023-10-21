//
//  HierarchyItemView.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 01.10.2023.
//

import Cocoa

final class HierarchyItemView: NSView {

	static var reuseIdentifier: String = "label"

	var status: Bool = false {
		didSet {
			updateUserInterface()
		}
	}

	var text: String = "" {
		didSet {
			updateUserInterface()
		}
	}

	var iconName: String = "doc" {
		didSet {
			updateUserInterface()
		}
	}

	var style: HierarchyModel.Style = .checkbox {
		didSet {
			updateUserInterface()
		}
	}

	var isFavorite: Bool = false {
		didSet {
			updateUserInterface()
		}
	}

	var number: Int = 0 {
		didSet {
			updateUserInterface()
		}
	}

	var textDidChange: ((String) -> Void)?

	var statusDidChange: ((Bool) -> Void)?

	// MARK: - UI-Properties

	lazy var imageView: NSImageView = {
		return NSImageView()
	}()

	lazy var textfield: NSTextField = {
		let view = NSTextField()
		view.focusRingType = .default
		view.cell?.sendsActionOnEndEditing = true
		view.isBordered = false
		view.drawsBackground = false
		view.usesSingleLineMode = true
		view.lineBreakMode = .byTruncatingMiddle
		view.font = NSFont.preferredFont(forTextStyle: .body)
		view.target = self
		view.action = #selector(textfieldDidChange(_:))
		return view
	}()

	lazy var checkbox: NSButton = {
		let view = NSButton()
		view.title = ""
		view.allowsMixedState = false
		view.setButtonType(.switch)
		view.image = NSImage(systemSymbolName: "app", accessibilityDescription: nil)
		view.alternateImage = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
		view.target = self
		view.action = #selector(checkboxDidChange(_:))
		return view
	}()

	lazy var badge: NSButton = {
		let view = NSButton()
		view.setButtonType(.momentaryChange)
		view.bezelStyle = .badge
		view.isHidden = true
		return view
	}()

	lazy var container: NSStackView = {
		let view = NSStackView(views: [checkbox, imageView, textfield, badge])
		view.orientation = .horizontal
		view.distribution = .fill
		view.alignment = .firstBaseline
		return view
	}()

	// MARK: - Initialization

	init() {
		super.init(frame: .zero)
		configureConstraints()
	}
	
	@available(*, unavailable, message: "Use init(textDidChange: checkboxDidChange:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - NSView life-cycle

	override func prepareForReuse() {
		super.prepareForReuse()
	}

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return textfield.becomeFirstResponder()
	}
}

// MARK: - Helpers
private extension HierarchyItemView {

	func updateUserInterface() {

		textfield.stringValue = text
		textfield.textColor = status ? .secondaryLabelColor : .labelColor

		badge.isHidden = number == 0
		badge.title = "\(number)"

		switch style {
		case .checkbox:
			checkbox.isHidden = false
			checkbox.state = status ? .on : .off
			imageView.isHidden = true && !isFavorite
			imageView.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
		case .list:
			checkbox.isHidden = true
			imageView.isHidden = false
			imageView.image = isFavorite
								? NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
								: NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
		case .icon(let name):
			checkbox.isHidden = true
			imageView.isHidden = false
			imageView.image = isFavorite
								? NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
								: NSImage(systemSymbolName: name, accessibilityDescription: nil)
		}
		imageView.contentTintColor = isFavorite && !status ? .systemYellow : .secondaryLabelColor
	}

	func configureConstraints() {

		[container].map { $0 }.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		[
			container.centerYAnchor.constraint(equalTo: centerYAnchor),
			container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
			container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
		]
			.forEach { $0.isActive = true }

	}
}

// MARK: - Actions
extension HierarchyItemView {

	@objc
	func textfieldDidChange(_ sender: NSTextField) {
		guard sender === textfield else {
			return
		}
		textDidChange?(sender.stringValue)
	}

	@objc
	func checkboxDidChange(_ sender: NSButton) {
		guard sender === checkbox else {
			return
		}
		statusDidChange?(sender.state == .on)
	}
}
