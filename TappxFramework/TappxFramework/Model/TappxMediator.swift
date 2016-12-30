//
//  TappxMediator.swift
//  TappxFramework
//
//  Created by David Alarcon on 22/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String : AnyObject]
public typealias JSONArray = [JSONDictionary]
public typealias JSONStringArray = [String: String]
public typealias SwapingParam = (key: String, value: String)
public typealias TappxEDictionary = [TappxE: Any]

struct TappxMediatorJSONConstants {
    static let conn_id = "conn_id"
    static let timeout = "timeout"
    static let mediation = "mediation"
    static let cn = "cn"
    static let e = "e"
    static let n = "n"
}

public enum TappxE: String {
    case tp = "tp"
    case adunit = "adunit"
    case timeout = "timeout"
    case data = "data"
}

public protocol JSONParser {
    
    init?(from json: JSONDictionary)
    static func fromJSON(from json: JSONDictionary) -> Self?
}

public final class TappxMediator: JSONParser {
    
    private(set) var conn_id: String
    private(set) var timeout: UInt
    private(set) var mediation: [TappxMediatorStep]
    
    public required init?(from json: JSONDictionary) {
        
        guard let conn_id = json[TappxMediatorJSONConstants.conn_id] as? String else { return nil }
        self.conn_id = conn_id
        
        guard let timeout = json[TappxMediatorJSONConstants.timeout] as? UInt else { return nil }
        self.timeout = timeout
        
        guard let steps = json[TappxMediatorJSONConstants.mediation] as? JSONArray else { return nil }
        self.mediation = []
        steps.forEach { json in
            _ = TappxMediatorStep.fromJSON(from: json).map { self.mediation.append($0) }
        }
    }

    public static func fromJSON(from json: JSONDictionary) -> TappxMediator? {
        let mediator = self.init(from: json)
        return mediator
    }
}

public struct TappxMediatorStep: JSONParser {
    
    public private(set) var cn: String
    public private(set) var e: TappxEDictionary
    public private(set) var n: String
    
    public init?(from json: JSONDictionary) {
        guard let cn = json[TappxMediatorJSONConstants.cn] as? String else { return nil }
        self.cn = cn
        
        guard let n = json[TappxMediatorJSONConstants.n] as? String else { return nil }
        self.n = n
        
        guard let ejson = json[TappxMediatorJSONConstants.e] as? JSONDictionary else { return nil }
        self.e = [:]
        if let params = ejson[TappxE.tp.rawValue] as? JSONStringArray {
            var tp: [SwapingParam] = []
            _ = params.map { param in tp.append(param) }
            self.e[.tp] = tp
        }
        _ = ejson[TappxE.adunit.rawValue].map { self.e[.adunit] = $0 }
        _ = ejson[TappxE.data.rawValue].map { self.e[.data] = $0 }
        _ = ejson[TappxE.timeout.rawValue].map { self.e[.timeout] = $0 }
    }
    
    public static func fromJSON(from json: JSONDictionary) -> TappxMediatorStep? {
        let step = self.init(from: json)
        return step
    }
    
}
