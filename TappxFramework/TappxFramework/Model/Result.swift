//
//  Result.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 13/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

//MARK: - Operators
infix operator >>  { associativity left precedence 160 }
infix operator ->> { associativity left precedence 160 }

func >><T, U>(left: Result<T>, right: (T) -> U) -> Result<U> {
    return left.map(right)
}

func ->><T, U>(left: Result<T>, right: (T) -> Result<U>) -> Result<U> {
    return left.flatMap(right)
}

//MARK: - Protocol
protocol ResultType {
    associatedtype Value
    
    init(success value: Value)
    init(failure error: ErrorType)
    
    func map<U>     (f: (Value) -> U) -> Result<U>
    func flatMap<U> (f: (Value) -> Result<U>) -> Result<U>
}

//MARK: - Result
public enum Result<T>: ResultType {
    case success(T)
    case failure(ErrorType)
}

extension Result {
    
    init(success value: T) {
        self = .success(value)
    }
    
    init(failure error: ErrorType) {
        self = .failure(error)
    }
    
    func value() -> T? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    func map<U>(f: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(f(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func flatMap<U>(f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .success(let value):
            return "success: \(String(value))"
        case .failure(let error as NSError):
            return "error: \(String(_cocoaString: error))"
        default:
            return "error"
        }
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success(let value):
            return "success: \(String(value))"
        case .failure(let error as NSError):
            return "error: \(String(_cocoaString: error))"
        default:
            return "error"
        }
    }
}

