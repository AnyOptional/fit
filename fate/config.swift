//
//  config.swift
//  fit
//
//  Created by Archer on 2018/10/19.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

struct Configration {
    var prefix: String
    var suffix: String
    var outputFileName: String
    var frameworkType: FrameworkType
    var outputFileType: OutputFileType
    
    // only valid when frameworkType == .YYModel
    var confirmsProtocol: BooleanType
    
    // only valid when outputFileType == .Swift
    var useInnerClass: BooleanType
    var ignorePrefix: BooleanType
}

extension Configration {
    
    enum FrameworkType: String {
        case None
        case YYModel
        case MJExtension
    }
    
    enum OutputFileType: String {
        case ObjC
        case Swift
    }
    
    enum BooleanType: String {
        case yes
        case no
    }
}

extension UserDefaults {
    
    func setConfig(_ config: Configration) {
        set(config.prefix, forKey: "kFitPrefixKey")
        set(config.suffix, forKey: "kFitSuffixKey")
        set(config.frameworkType.rawValue, forKey: "kFitFrameworkTypeKey")
        set(config.outputFileType.rawValue, forKey: "kFitOutputFileTypeKey")
        set(config.outputFileName, forKey: "kFitOutputFileNameKey")
        set(config.confirmsProtocol.rawValue, forKey: "kFitConfirmsProtocolKey")
        set(config.useInnerClass.rawValue, forKey: "kFitUseInnerClassKey")
        set(config.ignorePrefix.rawValue, forKey: "kFitIgnorePrefixKey")
        synchronize()
    }
    
    func getConfig() -> Configration {
        let prefix = string(forKey: "kFitPrefixKey") ?? ""
        let suffix = string(forKey: "kFitSuffixKey") ?? "Bean"
        let outputFileName = string(forKey: "kFitOutputFileNameKey") ?? "Fate"
        let frameworkType = Configration.FrameworkType(rawValue: string(forKey: "kFitFrameworkTypeKey") ?? "YYModel") ?? .YYModel
        let outputFileType = Configration.OutputFileType(rawValue: string(forKey: "kFitOutputFileTypeKey") ?? "Swift") ?? .Swift
        let useInnerClass = Configration.BooleanType(rawValue: string(forKey: "kFitUseInnerClassKey") ?? "yes") ?? .yes
        let ignorePrefix = Configration.BooleanType(rawValue: string(forKey: "kFitIgnorePrefixKey") ?? "yes") ?? .yes
        let confirmsProtocol = Configration.BooleanType(rawValue: string(forKey: "kFitConfirmsProtocolKey") ?? "yes") ?? .yes
        
        return Configration(prefix: prefix,
                            suffix: suffix,
                            outputFileName: outputFileName,
                            frameworkType: frameworkType,
                            outputFileType: outputFileType,
                            confirmsProtocol: confirmsProtocol,
                            useInnerClass: useInnerClass,
                            ignorePrefix: ignorePrefix)
    }
}
