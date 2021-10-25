import Foundation

public struct RequiredComponentConfig {
    public init(key: String, valueType: Any.Type, valueModifiable: Bool) {
        self.key = key
        self.valueType = valueType
        self.valueModifiable = valueModifiable
    }
    
    let key: String
    let valueType: Any.Type
    let valueModifiable: Bool
}

public protocol IDScanComponent: AnyObject {
    
    /**
     Component bundle. Required to be implemented and return "Bundle.module". See example
     
     ```
     public static func componentBundle() -> Bundle {
         Bundle.module
     }
     ```
     
     - Returns: Component Bundle.
     */
    static func componentBundle() -> Bundle
    
    /**
     Array of required configs with its types.
     
     If a component requires some configs (e. g. BaseURL for network requests) they can be returned by this method.
     There is a specific list of possible types. Example with all supported types:
     ```
     public static func requiredConfigs() -> [RequiredComponentConfig] {
         [RequiredComponentConfig(key: "BaseURL", valueType: String.self, valueModifiable: true),
          RequiredComponentConfig(key: "Valid Age", valueType: Int.self, valueModifiable: true),
          RequiredComponentConfig(key: "TimeStamp", valueType: Double.self, valueModifiable: false),
          RequiredComponentConfig(key: "Some date", valueType: Date.self, valueModifiable: false),
          RequiredComponentConfig(key: "USA States", valueType: Array<String>.self, valueModifiable: false),
          RequiredComponentConfig(key: "Some dic", valueType: [String : Any].self, valueModifiable: false)]
     }
     ```
     
     - Returns: Array of required configs with its types.
     */
    static func requiredConfigs() -> [RequiredComponentConfig]
}

extension IDScanComponent {
    
    /**
     Bundle of IDScanCore.
     
     - Returns: IDScanCore bundle.
     */
    static func coreBundle() -> Bundle {
        Bundle.module
    }
    
    /**
     Version of IDScanCore component
     
     - Returns: Version of IDScanCore component
     
     ```
     # Versioning: #
     major.yyyymmdd.build
     - major - increases after global changes
     - yyyymmdd - build date
     - build - increases with every build independently from other part of version
     ```
     */
    public static var coreVersion: String {
        let version = self.coreInfo["version"] as? String
        self.assertImportant(version?.count ?? 0 > 0, "Failed to get core component version")
        
        return version!
    }
    
    /**
     Version of component
     
     - Returns: Version of component
     
     ```
     # Versioning: #
     major.yyyymmdd.build
     - major - increases after global changes
     - yyyymmdd - build date
     - build - increases with every build independently from other part of version
     ```
     */
    public static var componentVersion: String {
        let version = self.componentInfo["version"] as? String
        self.assertImportant(version?.count ?? 0 > 0, "Failed to get component version")
        
        return version!
    }
    
    // MARK: - Public
    
    /**
     Name of component
     
     - Returns: Name of component
     */
    public static var componentName: String {
        let componentName = String(describing: self).split(separator: ".").first
        self.assertImportant(componentName?.count ?? 0 > 0, "Failed to get component name")
        
        return String(componentName!)
    }
    
    /**
     IDScanCore component info as a Dictionary. Contains version and other static parameters
     
     - Returns: IDScanCore component info as a Dictionary
     */
    public static var coreInfo: [String : Any] {
        if let infoURL = self.getPath(forCoreComponentResource: "ComponentInfo", ofType: "plist"),
           let info = NSDictionary(contentsOfFile: infoURL) as? [String : Any] {
            return info
        } else {
            self.assert("Failed to load ComponentInfo.plist")
        }
        
        return [:]
    }
    
    /**
     Component info as a Dictionary. Contains version and other static parameters
     
     - Returns: Component info as a Dictionary
     */
    public static var componentInfo: [String : Any] {
        if let infoURL = self.getPath(forComponentResource: "ComponentInfo", ofType: "plist"),
           let info = NSDictionary(contentsOfFile: infoURL) as? [String : Any] {
            return info
        } else {
            self.assert("Failed to load ComponentInfo.plist")
        }
        
        return [:]
    }
    
    /**
     Config of component as a Dictionary
     
     - Returns: Config of component as a Dictionary
     */
    public static var componentConfig: [String : Any]? {
        let componentName = self.componentName
        if let configs = self.componentConfigs(), let config = configs[componentName] as? [String : Any] {
            return config
        }
        
        return nil
    }
    
    /**
     Method for component asserts
     
     ```
     self.assertImportant(username != nil, "Username is nil")
     ```
     
     */
    public static func assertImportant(_ condition: Bool, _ message: String, _ withComponentName: Bool = false) {
        if withComponentName {
            precondition(condition, "\(self.componentName): \(message)")
        } else {
            precondition(condition, "IDScanComponents: \(message)")
        }
    }
    
    /**
     Method for component asserts
     
     ```
     self.assert("Username is nil")
     ```
     
     */
    public static func assert(_ message: String) {
        self.assertImportant(false, message, true)
    }
    
    /**
     Method for editing component configs
     
     ```
     self.setConfigValue(21, forKey: "Valid Age")
     ```
     
     */
    public static func setConfigValue(_ value: Any, forKey key: String) -> [Error] {
        let isKeyCanBeModified = self.requiredConfigs().firstIndex { (config: RequiredComponentConfig) -> Bool in
            return config.key == key && !config.valueModifiable
        } == nil
        
        if !isKeyCanBeModified {
            return [IDScanTextError(description: "\(self.componentName): " + "unable to save component config value '\(value)' for key '\(key)'. Required config key '\(key)' is not modifable")]
        }
        
        guard var componentConfig = self.componentConfig else {
            return [IDScanTextError(description: "\(self.componentName): " + "unable to save component config value '\(value)' for key '\(key)'. There is no IDScanComponents.plist file or component section '\(self.componentName)' in it")]
        }
        
        if componentConfig[key] == nil {
            return [IDScanTextError(description: "\(self.componentName): " + "unable to save component config value '\(value)' for key '\(key)'. The key is not exist. You can modify exist keys only.")]
        }
        
        componentConfig[key] = value
        return self.setComponentConfig(componentConfig)
    }
    
    public static func checkComponentConfig(_ config: [String : Any]?) -> [Error] {
        var errors: [Error] = []
        
        let requiredConfigs = self.requiredConfigs()
        
        for requiredConfig in requiredConfigs {
            if let configValue = config?[requiredConfig.key] {
                if !self.checkComponentConfigObjectType(configValue, isType: requiredConfig.valueType) {
                    errors.append(IDScanTextError(description: "REQUIRED CONFIG: wrong config value type for key '\(requiredConfig.key)'. Required: '\(requiredConfig.valueType)'. But in config: '\(type(of: configValue))'"))
                }
            } else {
                errors.append(IDScanTextError(description: "REQUIRED CONFIG: unable to load config value for key '\(requiredConfig.key)'"))
            }
        }
        
        return errors
    }
    
    public static func requiredConfigs() -> [RequiredComponentConfig] {
        []
    }
    
    // MARK: - Private
    static private func componentConfigs() -> [String : Any]? {
        if let configsURL = self.getComponentConfigsPath() {
            return NSDictionary(contentsOfFile: configsURL) as? [String : Any]
        }
        
        return nil
    }
    
    static private func setComponentConfig(_ config: [String : Any]) -> [Error] {
        let checkErrors = self.checkComponentConfig(config)
        if checkErrors.count > 0 {
            return checkErrors
        }
        
        guard var componentConfigs = self.componentConfigs(), let componentConfigsPath = self.getComponentConfigsPath() else {
            return [IDScanTextError(description: "\(self.componentName): " + "unable to save component config. There is no IDScanComponents.plist file or component section (\(self.componentName) in it" + "\n\(config)")]
        }
        
        componentConfigs[self.componentName] = config
        let succeed = (componentConfigs as NSDictionary).write(toFile: componentConfigsPath, atomically: true)
        
        if succeed {
            return []
        } else {
            return [IDScanTextError(description: "\(self.componentName): " + "unable to save component config. Can`t save to file \(componentConfigsPath)" + "\n\(config)")]
        }
    }
    
    static private func getComponentConfigsPath() -> String? {
        return self.getPath(forComponentDependantResource: "IDScanComponents", ofType: "plist")
    }
    
    static private func getPath(forCoreComponentResource name: String, ofType ext: String) -> String? {
        let path = self.coreBundle().path(forResource: name, ofType: ext)
        return path
    }
    
    static private func getPath(forComponentResource name: String, ofType ext: String) -> String? {
        let path = self.componentBundle().path(forResource: name, ofType: ext)
        return path
    }
    
    static private func getPath(forComponentDependantResource name: String, ofType ext: String) -> String? {
        if let path = Bundle.main.path(forResource: name, ofType: ext) {
            return path
        }
        
        return self.getTestPath(forComponentDependantResource: name, ofType: ext)
    }
    
    static func checkComponentConfigObjectType(_ object: Any, isType type: Any.Type) -> Bool {
        switch object {
        case _ as String:
            return type == String.self
        case _ as Int:
            return type == Int.self
        case _ as Double:
            return type == Double.self
        case _ as Date:
            return type == Date.self
        case _ as Array<Any>:
            return type == Array<Any>.self
        case _ as [String : Any]:
            return type == [String : Any].self
        default:
            return false
        }
    }
}

// MARK: - For tests
extension IDScanComponent {
    static private func getTestPath(forComponentDependantResource name: String, ofType ext: String) -> String? {
        let bundle = Bundle(for: self)
        let bundlePathSplit = bundle.bundlePath.split(separator: "/")
        
        let firstPartOfBundleFileName = String((self.componentBundle().bundlePath.split(separator: "/").last?.split(separator: "_").first)!)
        let dependantName = firstPartOfBundleFileName + "Tests"
        let bundleFileName = firstPartOfBundleFileName + "_" + dependantName + ".bundle"
        
        let bundlePath = "/" + bundlePathSplit[..<(bundlePathSplit.count - 1)].joined(separator: "/") + "/" + bundleFileName
        
        if let targetBundle = Bundle(path: bundlePath) {
            let path = targetBundle.path(forResource: name, ofType: ext)
            return path
        }
        
        return nil
    }
}
