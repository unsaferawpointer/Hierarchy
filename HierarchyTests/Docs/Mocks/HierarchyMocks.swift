//
//  HierarchyMocks.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation
@testable import Hierarchy

struct HierarchyMocks {

	static let containers: [ItemEntity] =
	[
		.init(
			uuid: .uuid1,
			content: .init(text: "item 0", isDone: false, iconName: "doc"),
			options: .badge,
			items:
				[
					.init(
						uuid: .uuid2,
						content: .init(text: "item 00", isDone: true, iconName: "doc"),
						options: .checkbox
					)
				]
		),
		.init(
			uuid: .uuid3,
			content: .init(text: "item 1", isDone: false, iconName: "doc"),
			options: .badge
		)
	]
}
