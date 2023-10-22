//
//  IconCagetory.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 22.10.2023.
//

import Foundation

struct IconCategory {

	var title: String

	var icons: [String]

	// MARK: - Initialization

	init(title: String, icons: [String]) {
		self.title = title
		self.icons = icons
	}
}

// MARK: - Icons sets
extension IconCategory {

	static let objectsAndTools: IconCategory = .init(
		title: "Objects & Tools",
		icons:
			[
				"folder.fill",
				"archivebox.fill",
				"doc.fill",
				"doc.text.fill",
				"note.text",
				"book.closed.fill",
				"creditcard.fill",
				"hammer.fill",
				"flask.fill",
				"cube.fill",
				"slider.horizontal.2.square"
			]
	)

	static let sport: IconCategory = .init(
		title: "Sport",
		icons:
			[
				"baseball.fill",
				"basketball.fill",
				"football.fill",
				"tennisball.fill",
				"volleyball.fill",
				"skateboard.fill",
				"skis.fill",
				"snowboard.fill",
				"surfboard.fill"
			]
	)

	static let devices: IconCategory = .init(
		title: "Devices",
		icons:
			[
				"keyboard.fill",
				"printer.fill",
				"scanner.fill",
				"display",
				"laptopcomputer",
				"headphones",
				"av.remote.fill",
				"tv.fill",
				"gamecontroller.fill",
				"camera.fill",
				"candybarphone",
				"smartphone",
				"simcard.fill",
				"sdcard.fill"
			]
	)

	static let health: IconCategory = .init(
		title: "Health",
		icons:
			[
				"cross.case.fill",
				"pills.fill",
				"cross.fill",
				"flask.fill",
				"cross.vial.fill",
				"heart.text.square.fill",
				"syringe.fill",
				"medical.thermometer.fill",
				"microbe.fill",
				"bandage.fill"
			]
	)

	static let life: IconCategory = .init(
		title: "Everyday life",
		icons:
			[
				"tshirt.fill",
				"shoe.fill",
				"comb.fill",
				"cup.and.saucer.fill",
				"wineglass.fill",
				"fork.knife",
				"bag.fill",
				"gym.bag.fill",
				"suitcase.fill"
			]
	)
}

extension IconCategory {

	static var categories: [IconCategory] =
	[
		.objectsAndTools,
		.sport,
		.devices,
		.health,
		.life
	]
}
