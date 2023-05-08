//
//  Dictionary + Extension.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 07.05.2023.
//

import Foundation

extension Dictionary {

	@discardableResult
	mutating func removeValues(forKeys keys: [Key]) -> [Value?] {
		var result: [Value?] = []
		keys.forEach {
			let deleted = removeValue(forKey: $0)
			result.append(deleted)
		}
		return result
	}

	subscript(unsafe key: Key) -> Value {
		guard let value = self[key] else {
			fatalError()
		}
		return value
	}
}
