//
//  IDScanCoreTestModel.swift
//  
//
//  Created by AKorotkov on 02.03.2021.
//

import Foundation
import IDScanCore

public class IDScanCoreTestModel: IDScanComponent {
    public static func componentBundle() -> Bundle {
        Bundle.module
    }
    
    public static func requiredConfigs() -> [RequiredComponentConfig] {
        [RequiredComponentConfig(key: "TestString", valueType: String.self, valueModifiable: true),
         RequiredComponentConfig(key: "TestInt", valueType: Int.self, valueModifiable: true),
         RequiredComponentConfig(key: "TestDouble", valueType: Double.self, valueModifiable: false),
         RequiredComponentConfig(key: "TestDate", valueType: Date.self, valueModifiable: false),
         RequiredComponentConfig(key: "TestArray", valueType: Array<Any>.self, valueModifiable: false),
         RequiredComponentConfig(key: "TestDic", valueType: [String : Any].self, valueModifiable: false)
        ]
    }
}
