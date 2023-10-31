//
//  HierarchyMocks.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation
@testable import Hierarchy

struct HierarchyMocks {

	static let containers: [Node<ItemContent>] =
	[
		.init(
			value: .init(uuid: .uuid1, text: "item 0", isDone: false, iconName: "doc", count: 0, options: .favorite),
			children:
				[
					.init(
						value: .init(
							uuid: .uuid2,
							text: "item 00",
							isDone: true, 
							iconName: "doc",
							count: 7,
							options: .empty
						),
						children: []
					)
				]
		),
		.init(
			value: .init(
				uuid: .uuid3,
				text: "item 1",
				isDone: false,
				iconName: "doc",
				count: 0,
				options: .favorite
			)
		)
	]
}
