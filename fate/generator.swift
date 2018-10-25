//
//  generator.swift
//  fit
//
//  Created by Archer on 2018/10/24.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

// MARK: GeneratorType
protocol GeneratorType {
    func generateFile() throws
}

// MARK: Context
class Context {
    
    let fate: Fate?
    let generator: GeneratorType?
    
    init(_ fate: Fate?) {
        self.fate = fate
        guard let config = fate?.config,
            let jsonString = fate?.jsonString else {
            generator = nil
            return
        }
        if config.outputFileType == .Swift {
            generator = SwiftFileGenerator(config, jsonString)
        } else {
            generator = ObjectiveCFileGenerator(config, jsonString)
        }
    }
    
    func generate() throws {
        try generator?.generateFile()
    }
}

// MARK: Supporting
let NSIntEncodingType = "q"
let NSDoubleEncodingType = "d"
func NSFileWritingDirectory() throws -> String  {
    let filepath = NSHomeDirectory() + "/Desktop/fit"
    try FileManager.default.createDirectory(atPath: filepath, withIntermediateDirectories: true, attributes: nil)
    return filepath
}
