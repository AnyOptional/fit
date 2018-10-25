//
//  error.swift
//  fit
//
//  Created by Archer on 2018/10/19.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

enum GenerationError: Error, CustomStringConvertible {
    
    // 参数非法
    case unexpectArguments
    
    // 不是一个文件
    case unsuppotedFile(atPath: String)
    
    // 读取文件失败
    case readFileFailed(atPath: String)
    
    // 缺失参数值
    case valueMissing(atParameter: String)
    
    // 参数值不匹配
    case valueMismatch(atParameter: String, wrongValue: String, correctValues: String...)
    
    // 不支持的参数
    case unsupportedParameter(parameter: String)
    
    // 无效的json
    case jsonStringNotValid(jsonString: String)
    
    var description: String {
        switch self {
        case .unexpectArguments:
            return "Usage: fit ExampleJson.txt -o ExampleModel -t swift"

        case let .unsuppotedFile(filepath):
            return "\"\(filepath)\" is not a readable file"
            
        case let .readFileFailed(filepath):
            return "Unable to read input file at \"\(filepath)\""
            
        case let .valueMissing(parameter):
            return "missing value for parameter \"\(parameter)\" "
            
        case let .valueMismatch(parameter, wrongValue, correctValues):
            return "value for parameter \"\(parameter)\" should be one of \(correctValues), not \"\(wrongValue)\""
            
        case let .unsupportedParameter(parameter):
            return "parameter \"\(parameter)\" currently not supported yet"
            
        case let .jsonStringNotValid(jsonString):
            return "json string \"\(jsonString)\" can not convert to dictionary type, e.g., root object must be a dictionary"
        }
    }
}
