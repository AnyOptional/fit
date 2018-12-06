
//
//  ObjectiveCFileGenerator.swift
//  fit
//
//  Created by Archer on 2018/10/25.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

// MARK: ObjectiveCFileGenerator
class ObjectiveCFileGenerator {
    
    let jsonString: String
    let config: Configration
    
    private var outputHeaderStack = Stack<String>()
    private var outputImplementationStack = Stack<String>()
    
    init(_ config: Configration, _ jsonString: String) {
        self.config = config
        self.jsonString = jsonString
    }
}

extension ObjectiveCFileGenerator: GeneratorType {
    func generateFile() throws {
        let json = JSON(parseJSON: jsonString)
        if json.type == .dictionary {
            outputHeaderStack.push("NS_ASSUME_NONNULL_END")
            
            if config.frameworkType == .YYModel {
                if config.confirmsProtocol == .yes {
                    outputHeaderStack.push("""
                        @interface \(config.outputFileName) : NSObject<YYModel> \n
                        """)
                } else {
                    outputHeaderStack.push( """
                        @interface \(config.outputFileName) : NSObject \n
                        """)
                }
            } else if config.frameworkType == .MJExtension {
                outputHeaderStack.push("""
                    @interface \(config.outputFileName) : NSObject \n
                    """)
            } else {
                outputHeaderStack.push("""
                    @interface \(config.outputFileName) : NSObject \n
                    """)
            }
            
            outputImplementationStack.push("""
                @implementation \(config.outputFileName)\n
                """)
            
            let jsonValue = json.dictionaryValue
            try generate(from: jsonValue)
            try writeToFile()
        } else {
            throw GenerationError.jsonStringNotValid(jsonString: jsonString)
        }
    }
    
    private func generate(from dictionaryValue: [String : JSON]) throws {
        var allGenericTypes = [String: String]()
        var classKeyPairs = [String : [String : JSON]]()
        for (key, value) in dictionaryValue {
            guard !key.isEmpty else {
                print("-fit: the key corresponding to the \"\(value)\" is missing")
                continue
            }
            switch value.type {
            case .number:
                if strcmp(value.numberValue.objCType, NSIntEncodingType) == 0 {
                    outputHeaderStack += "@property (nonatomic, assign) NSInteger \(key);\n"
                } else { // hold every number type
                    outputHeaderStack += "@property (nonatomic, assign) CGFloat \(key);\n"
                }
                
            case .string:
                outputHeaderStack += "@property (nonatomic, copy) NSString *\(key);\n"
                
            case .bool:
                outputHeaderStack += "@property (nonatomic, assign) BOOL \(key);\n"
                
            case .array:
                if value.arrayValue.isEmpty { continue }
                let jsonValue = value.arrayValue.first!
                try generate(key: key, jsonValue: jsonValue, genericTypes: &allGenericTypes, classKeyPairs: &classKeyPairs)
                
            case .dictionary:
                let prefix = key[key.startIndex..<key.index(after: key.startIndex)].uppercased()
                let suffix = key[key.index(after: key.startIndex)..<key.endIndex]
                let genericType = config.prefix + "\(prefix + suffix)" + config.suffix
                
                classKeyPairs[genericType] = value.dictionaryValue
                outputHeaderStack += "@property (nonatomic, strong) \(genericType) *\(key);\n"
                
            case .null, .unknown: break
            }
        }
        
        if !allGenericTypes.isEmpty {
            var generics = ""
            let retracts = "\t\t\t "
            for (key, value) in allGenericTypes {
                generics += "@\"\(key)\" : \(value).class,\n\(retracts)"
            }
            generics.removeLast(retracts.count + 2)
            if config.frameworkType == .YYModel {
                outputImplementationStack += """
                + (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
                    return @{\(generics)};
                }\n
                """
            } else if config.frameworkType == .MJExtension {
                outputImplementationStack += """
                + (NSDictionary *)mj_objectClassInArray { {
                    return @{\(generics)};
                }\n
                """
            } else {
                // nothing goes here
            }
        }
        
        outputHeaderStack += "@end\n\n"
        outputImplementationStack += "@end\n\n"
        
        for (className, keyPairs) in classKeyPairs {
            if config.frameworkType == .YYModel &&
                config.confirmsProtocol == .yes {
                outputHeaderStack.push("""
                    @interface \(className) : NSObject<YYModel> \n
                    """)
            } else {
                outputHeaderStack.push("""
                    @interface \(className) : NSObject \n
                    """)
            }
            outputImplementationStack.push("""
                @implementation \(className)\n
                """)
            
            try generate(from: keyPairs)
        }
    }
    
    private func generate(key: String, jsonValue: JSON, genericTypes: inout [String: String], classKeyPairs: inout [String : [String : JSON]]) throws {
        guard !key.isEmpty else {
            print("-fit: the key corresponding to the \"\(jsonValue)\" is missing")
            return
        }        
        switch jsonValue.type {
        case .number, .bool:
            outputHeaderStack += "@property (nonatomic, strong) NSArray<NSNumber *> *\(key);\n"
            
        case .string:
            outputHeaderStack += "@property (nonatomic, strong) NSArray<NSString *> *\(key);\n"
            
        case .array:
            print("-fit: two-dimensional arrays are not supported yet")
            
        case .dictionary:
            let prefix = key[key.startIndex..<key.index(after: key.startIndex)].uppercased()
            let suffix = key[key.index(after: key.startIndex)..<key.endIndex]
            let genericType = config.prefix + "\(prefix + suffix)" + config.suffix
            
            genericTypes[key] = genericType
            classKeyPairs[genericType] = jsonValue.dictionaryValue
            outputHeaderStack += "@property (nonatomic, strong) NSArray<\(genericType) *> *\(key);\n"
            
        case .null:
            print("-fit: null find at \"\(key)\"")
                
        case .unknown:
            print("-fit: unknown json type detected at \"\(key)\"")
        }
    }
    
    private func writeToFile() throws {
        let filepath = try NSFileWritingDirectory()
        let header = "/" + config.outputFileName + ".h"
        outputHeaderStack.push("""
            //
            //  \(config.outputFileName).h
            //
            //  This file is auto generated by fit.
            //  Github: https://github.com/AnyOptional/fit
            //
            //  Copyright © 2018-present Archer. All rights reserved.
            //
            
            #import <UIKit/UIKit.h>\n
            """)
        if config.frameworkType == .YYModel {
            if config.confirmsProtocol == .yes {
                outputHeaderStack += """
                #import <YYKit/NSObject+YYModel.h>\n
                NS_ASSUME_NONNULL_BEGIN \n\n
                """
            } else {
                outputHeaderStack += """
                
                NS_ASSUME_NONNULL_BEGIN \n\n
                """
            }
        } else if config.frameworkType == .MJExtension {
            outputHeaderStack += """
            #import <MJExtension/MJExtension.h>\n
            NS_ASSUME_NONNULL_BEGIN \n\n
            """
        } else {
            outputHeaderStack += """
            
            NS_ASSUME_NONNULL_BEGIN \n\n
            """
        }
        
        outputImplementationStack.push("""
            //
            //  \(config.outputFileName).m
            //
            //  This file is auto generated by fit.
            //  Github: https://github.com/AnyOptional/fit
            //
            //  Copyright © 2018-present Archer. All rights reserved.
            //
            
            #import "\(config.outputFileName).h"\n\n
            """)
        
        let implementation = "/" + config.outputFileName + ".m"
        try outputHeaderStack.reversed().joined().write(toFile: filepath + header, atomically: true, encoding: .utf8)
        try outputImplementationStack.reversed().joined().write(toFile: filepath + implementation, atomically: true, encoding: .utf8)
    }
}
