//
//  ItemContent.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 30.09.2023.
//

import Foundation

struct ItemContent {

	var text: String

	var isDone: Bool

	var iconName: String

	var value: Int = 0
}

// MARK: - Equatable
extension ItemContent: Equatable { }

// MARK: - Hashable
extension ItemContent: Hashable { }

// MARK: - Decodable
extension ItemContent: Decodable {

	enum CodingKeys: CodingKey {
		case text
		case isDone
		case iconName
		case value
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let text = try container.decode(String.self, forKey: .text)
		let isDone = try container.decode(Bool.self, forKey: .isDone)
		let iconName = try container.decode(String.self, forKey: .iconName)
		let value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
		self.init(text: text, isDone: isDone, iconName: iconName, value: value)
	}
}

// MARK: - Encodable
extension ItemContent: Encodable {

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(text, forKey: .text)
		try container.encode(isDone, forKey: .isDone)
		try container.encode(iconName, forKey: .iconName)
		try container.encode(value, forKey: .value)
	}
}
