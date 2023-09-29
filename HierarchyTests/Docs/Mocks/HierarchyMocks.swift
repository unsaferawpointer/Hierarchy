//
//  HierarchyMocks.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 29.09.2023.
//

import Foundation
@testable import Hierarchy

struct HierarchyMocks {

	static let containers: [Container] = 
	[
		.section(uuid: .uuid1, icon: "folder", text: "It is section", items:
					[
						.list(uuid: .uuid2, icon: "doc", text: "It is list", todos:
								[
									.init(uuid: .uuid3, text: "Todo 0"),
									.init(uuid: .uuid4, text: "Todo 1")
								]
							 )
					]
				),
		.list(uuid: .uuid5, icon: "doc", text: "It is list", todos:
				[
					.init(uuid: .uuid6, text: "Todo 0"),
					.init(uuid: .uuid7, text: "Todo 1")
				]
			 )
	]
}
