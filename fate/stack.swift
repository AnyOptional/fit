//
//  stack.swift
//  fit
//
//  Created by Archer on 2018/10/19.
//  Copyright © 2018年 Archer. All rights reserved.
//

import Foundation

class Stack<E> {
    private var _storage = [E]()
    
    var top: E? {
        return _storage.last
    }
    
    var count: Int {
        return _storage.count
    }
    
    var isEmpty: Bool {
        return _storage.isEmpty
    }
    
    @discardableResult
    func pop() -> E? {
        if isEmpty { return nil }
        return _storage.removeLast()
    }
    
    func push(_ e: E) {
        _storage.append(e)
    }
}

extension Stack where E == String {
    func joined() -> String {
        return _storage.joined()
    }
    
    func reversed() -> [String] {
        return _storage.reversed()
    }
    
    static func +=(lhs: Stack<String>, rhs: String) {
        if lhs.isEmpty {
            print("-fit: Stack is empty, += will be a non-op")
        } else {
            lhs._storage[lhs.count - 1] += rhs
        }
    }
}
