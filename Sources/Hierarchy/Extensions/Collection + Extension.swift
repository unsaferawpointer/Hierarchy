//
//  Collection + Extension.swift
//  
//
//  Created by Anton Cherkasov on 12.05.2023.
//

import Foundation

extension Collection {

	public func firstIndex<Value: Equatable>(where keyPath: KeyPath<Element, Value>, equalsTo value: Value) -> Index? {
		return firstIndex { $0[keyPath: keyPath] == value }
	}
}
