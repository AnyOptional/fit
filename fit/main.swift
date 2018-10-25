//
//  main.swift
//  fit
//
//  Created by Archer on 2018/10/19.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

do {
    // 写文件
    let writingDirectory = try NSFileWritingDirectory()
    let filePath = writingDirectory + "/json.txt"
    try jsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
    
    ///  格式 fit json文件路径 参数 参数值 其他参数 其他参数值 ...
    ///  -t Swift/ObjC 输出为swift或OC文件
    ///  -o XXX 输出文件名和顶层对象名为XXX
    ///  -f MJExtension/YYModel/None 使用的json解析框架 None表示不用
    ///  -p 类名的前缀
    ///  -s 类名的后缀
    ///     类名由 前缀 + jsonKey + 后缀
    ///     例如： {"data": { "addressDetails": "string" }}
    ///     若前缀为NS，后缀为Model，那么data对应的对象名为 NSDataModel
    ///  -i -u 两个参数在 -t为Swift时有效，-u 是否使用嵌套类 -i 是否忽略类名前缀
    ///  -c YYModel中NSObject并未遵守YYModel协议，MJExtension中都遵守了MJKeyValue -c指明在使用YYModel时是否需要让类遵守YYModel协议
    let args = "fit \(filePath) -t Swift -o YourModel -f MJExtension -p MAS -s Model -i no -u no -c yes"
    let arguments =  args.split(separator: " ").map { String($0) } // CommandLine.arguments
    let fate = try Fate(arguments)
    let ctx = Context(fate)
    try ctx.generate()
    print("-fit: Please check newer created file at \"\(writingDirectory)\".")
} catch let error as GenerationError {
    print("-fit: " + error.description)
} catch {
    print("-fit: \(error)")
}
