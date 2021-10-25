import XCTest
import IDScanCore
import IDScanCoreTestModel
import IDScanComponentTests

class IDScanCoreTests: XCTestCase {
    func test() {
        var errors: [Error] = []
        
        errors.append(contentsOf: self.testComponent(IDScanCoreTestModel.self))
        
        errors.append(contentsOf: self.testComponentConfigModifying(IDScanCoreTestModel.self))
        
        if let formattedErrors = self.formatErrors(errors, componentName: IDScanCoreTestModel.componentName) {
            XCTFail(formattedErrors)
        }
    }
    
    func testComponentConfigModifying(_ component: IDScanComponent.Type) -> [Error] {
        var errors: [Error] = []
        
        let requiredKeyToSetWrongValueType = "TestString"
        let setWrongValueTypeForRequiredKeyErrors = component.setConfigValue(123, forKey: requiredKeyToSetWrongValueType)
        if setWrongValueTypeForRequiredKeyErrors.count == 0 {
            errors.append(IDScanTextError(description: "REQUIRED CONFIG: it is possible to set a value with wrong type 'Int' for required config '\(requiredKeyToSetWrongValueType)' with type 'String'"))
        }
        
        let requiredUnmodifiableKeyToSetValue = "TestDouble"
        let setUnmodifiableRequiredKeyErrors = component.setConfigValue(123.0, forKey: requiredUnmodifiableKeyToSetValue)
        if setUnmodifiableRequiredKeyErrors.count == 0 {
            errors.append(IDScanTextError(description: "REQUIRED CONFIG: it is possible to set a value for unmodifiable required config '\(requiredUnmodifiableKeyToSetValue)'"))
        }
        
        let addingNonexistentKeyValue = "TestNewKey"
        let addingNonexistentKeyErrors = component.setConfigValue(123.0, forKey: addingNonexistentKeyValue)
        if addingNonexistentKeyErrors.count == 0 {
            errors.append(IDScanTextError(description: "REQUIRED CONFIG: it is possible to add nonexistent config"))
        }
        
        return errors
    }
}

extension IDScanCoreTestModel: IDScanComponentTest {
    public static func selfTest() -> [Error] {
        []
    }
}
