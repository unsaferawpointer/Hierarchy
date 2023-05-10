//
//  ReferenceIdentifiable.swift
//  
//
//  Created by Anton Cherkasov on 08.05.2023.
//

public protocol ReferenceIdentifiable: AnyObject { }

// MARK: - Identifiable
extension ReferenceIdentifiable {

	var id: ObjectIdentifier {
		return ObjectIdentifier(self)
	}
}
