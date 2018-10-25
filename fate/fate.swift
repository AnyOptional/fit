//
//  fate.swift
//  fit
//
//  Created by Archer on 2018/10/19.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

class Fate {
    
    let jsonString: String?
    
    let config: Configration?
    
    init?(_ arguments: [String]) throws {
        // 校验有效性
        guard !arguments.isEmpty else {
            return nil
        }
        guard arguments[0] == "fit" else {
            return nil
        }
        guard arguments.count > 1 else {
            throw GenerationError.unexpectArguments
        }
        
        // 提取第一个参数
        let argument = arguments[1]
        if argument == "--help" {
            config = nil
            jsonString = nil
            printFateOverview()
            
        } else {
            // 读取输入文件
            guard FileManager.default.isReadableFile(atPath: argument) else {
                throw GenerationError.unsuppotedFile(atPath: argument)
            }
            // 转换成json格式字符串
            guard let originalJsonAtFileContent = try? String(contentsOfFile: argument, encoding: .utf8) else {
                throw GenerationError.readFileFailed(atPath: argument)
            }
            jsonString = originalJsonAtFileContent
            config = UserDefaults.standard.getConfig()
            // 提取配置参数
            let argv = Array(arguments.dropFirst(2))
            var i = 0
            while i < argv.count {
                if argv[i].hasPrefix("-") && (i + 1 < argv.count) {
                    switch argv[i] {
                    case "-o":
                        config?.outputFileName = argv[i + 1]
                        
                    case "-t":
                        guard let outputFileType = Configration.OutputFileType(rawValue: argv[i + 1]) else {
                            throw GenerationError.valueMismatch(atParameter: argv[i], wrongValue: argv[i + 1], correctValues: "ObjC", "Swift")
                        }
                        config?.outputFileType = outputFileType
                        
                    case "-f":
                        guard let frameworkType = Configration.FrameworkType(rawValue: argv[i + 1]) else {
                            throw GenerationError.valueMismatch(atParameter: argv[i], wrongValue: argv[i + 1], correctValues: "None", "YYModel", "MJExtension")
                        }
                        config?.frameworkType = frameworkType
                        
                    case "-p":
                        config?.prefix = argv[i + 1]
                        
                    case "-s":
                        config?.suffix = argv[i + 1]
                        
                    case "-c":
                        guard let confirmsProtocol = Configration.BooleanType(rawValue: argv[i + 1]) else {
                            throw GenerationError.valueMismatch(atParameter: argv[i], wrongValue: argv[i + 1], correctValues: "yes", "no")
                        }
                        config?.confirmsProtocol = confirmsProtocol
                        
                    case "-u":
                        guard let useInnerClass = Configration.BooleanType(rawValue: argv[i + 1]) else {
                            throw GenerationError.valueMismatch(atParameter: argv[i], wrongValue: argv[i + 1], correctValues: "yes", "no")
                        }
                        config?.useInnerClass = useInnerClass
                        
                    case "-i":
                        guard let ignorePrefix = Configration.BooleanType(rawValue: argv[i + 1]) else {
                            throw GenerationError.valueMismatch(atParameter: argv[i], wrongValue: argv[i + 1], correctValues: "yes", "no")
                        }
                        config?.ignorePrefix = ignorePrefix
                        
                    default: throw GenerationError.unsupportedParameter(parameter: argv[i])
                    }
                } else {
                    throw GenerationError.valueMissing(atParameter: argv[i])
                }
                i += 2
            }
        }
    }
}

extension Fate {
    func printFateOverview() {
        let help = """

fit --help:
     -o: output 输出文件名
     -t: type 输出文件类型
     -f: framework 使用的JSON转模型框架
     -s: suffix 类名的后缀
     -p: prefix 类名的前缀
     -u: use 输出为swift文件时使用内部类的形式
     -i: ignore 当swift文件使用内部类时忽略类名前缀
     -c: confirm 使用JSON转模型框架时是否遵守对应协议

     Example: fit ExampleJson.txt -o ExampleModel -t objc -f YYModel

"""
        print(help)
    }
}
