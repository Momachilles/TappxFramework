//
//  Future.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 13/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

public protocol FutureType {
    associatedtype R
    associatedtype Value
    
    init(value: R)
    
    func map<U>(f: (Value) -> U) -> Future<U>
    func flatMap<U>(f: (Value) -> Result<U>) -> Future<U>
    func then<U>(f: (Value) -> U) -> Future<U>
}

public struct Future<T>: FutureType {
    
    public typealias ResultType = Result<T>
    public typealias Completion = (ResultType) -> ()
    public typealias AsyncOperation = (Completion) -> ()
    
    public let operation: AsyncOperation
    
    public init(value result: ResultType) {
        self.init { completion in
            completion(result)
        }
    }
    
    public init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    public func start(completion: Completion) {
        self.operation { result in
            completion(result)
        }
    }
    
    public func map<U>(f: (T) -> U) -> Future<U> {
        return Future<U>(operation: { completion in
            self.start { result in
                switch result {
                case .success(let value):
                    completion(.success(f(value)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        })
    }
    
    public func flatMap<U>(f: (T) -> Result<U>) -> Future<U> {
        return Future<U>(operation: { completion in
            self.start { result in
                switch result {
                case .success(let value):
                    completion(f(value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        })
    }
    
    public func then<U>(f: (T) -> U) -> Future<U> {
        return self.map(f)
    }
}

extension Future {
    
    

}
