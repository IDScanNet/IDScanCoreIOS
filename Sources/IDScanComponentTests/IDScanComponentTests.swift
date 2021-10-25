//
//  IDScanComponentTests.swift
//  
//
//  Created by AKorotkov on 04.03.2021.
//

import Foundation
import XCTest
import IDScanCore

public protocol IDScanComponentTest: IDScanComponent {
    
    /**
     Method for component self testing
     
     ```
     public static func selfTest() -> [Error] {
        if some check is invalid {
            return ["some check is invalid"]
        }
     }
     ```
     
     - Returns: Array of errors.
     */
    static func selfTest() -> [Error]
}

extension XCTestCase {
    public func testComponent(_ component: IDScanComponentTest.Type) -> [Error] {
        var errors: [Error] = []
        errors.append(contentsOf: self.testVersion(component: component))
        errors.append(contentsOf: self.testGetConfigRequiredConfigs(component: component))
        errors.append(contentsOf: component.selfTest())
        return errors
    }
    
    fileprivate func testVersion(component: IDScanComponent.Type) -> [Error] {
        var errors: [Error] = []
        
        if !self.validateVersion(component.componentVersion) {
            errors.append(IDScanTextError(description: "VERSION: wrong version format '\(component.componentVersion)'"))
        }
        if !self.validateVersion(component.coreVersion) {
            errors.append(IDScanTextError(description: "VERSION: wrong core version format '\(component.coreVersion)'"))
        }
        
        return errors
    }
    
    fileprivate func testGetConfigRequiredConfigs(component: IDScanComponent.Type) -> [Error] {
        return component.checkComponentConfig(component.componentConfig)
    }
    
    fileprivate func validateVersion(_ version: String) -> Bool {
        let coreVersionNumbers = version.split(separator: ".")
        return coreVersionNumbers.count == 3 && coreVersionNumbers[1].count == 8
    }
    
    public func formatErrors(_ errors: [Error], componentName: String) -> String? {
        if errors.count == 0 {
            return nil
        }
        
        let newLineCorrectedErrors = errors.map { (error) -> String in
            return error.localizedDescription.replacingOccurrences(of: "\n", with: "\n    ")
        }
        
        let bottomSeparator = String(repeating: "#", count: 100)
        let topSeparator = "## \(componentName) Errors: " + bottomSeparator.dropLast(componentName.count + 12)
//        let middleSeparator = String(repeating: "-", count: 95)
        
        let formattedErrors = "\n\n\n\(topSeparator)\n\n" + " -> " + newLineCorrectedErrors.joined(separator: "\n\n -> ") + "\n\n\(bottomSeparator)\n\n\n"
        
        return formattedErrors
    }
    
    public func assertErrors(errors: [Error], componentName: String) {
        if let formattedErrors = self.formatErrors(errors, componentName: componentName) {
            XCTFail(formattedErrors)
        }
    }
}
