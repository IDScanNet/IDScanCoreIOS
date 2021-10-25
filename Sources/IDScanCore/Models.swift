//
//  Models.swift
//  
//
//  Created by AKorotkov on 11.05.2021.
//

import Foundation

public struct IDScanTextError: LocalizedError {
    let description: String
    
    public init(description: String) {
        self.description = description
    }
    
    public var errorDescription: String? {
        return description
    }
    
    public var failureReason: String? {
        return description
    }
}
