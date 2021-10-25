# IDScanCore

Core component. Includes IDScanComponent protocol with base component methods and base test methods.

Targets, using the components, must specify required config params for the components in the file IDScanComponents.plist. It must be a Dictionary, where keys are the component names and values are Dictionaries with params.

Every component can implement func requiredConfigs() -> [RequiredComponentConfig] to specify which params are required for proper work. The correctness of these parameters will be checked during tests.

Every component must include a file named ComponentInfo.plist with key "version".
Versioning:
    major.yyyymmdd.build
    major - increases after global changes
    yyyymmdd - build date
    build - increases with every build independently from other part of version
