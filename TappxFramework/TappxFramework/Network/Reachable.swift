//
//  Reachable.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 13/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum ReachabilityType {
    case online
    case offline
}

extension ReachabilityType {
    public init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.ConnectionRequired)
        let isReachable = flags.contains(.Reachable)
        self = (!connectionRequired && isReachable) ? .online : .offline
    }
}

extension ReachabilityType: CustomDebugStringConvertible  {
    public var debugDescription: String {
        switch self {
        case .online(let type):
            return "online (\(type))"
        case .offline:
            return "offline"
        }
    }
}

extension ReachabilityType: CustomStringConvertible  {
    public var description: String {
        switch self {
        case .online(let type):
            return "online (\(type))"
        case .offline:
            return "offline"
        }
    }
}

public protocol Reachable {
    var reachable: ReachabilityType { get }
}

extension Reachable {
    
    var reachable: ReachabilityType {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return ReachabilityType.offline
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? ReachabilityType.online : ReachabilityType.offline

    }
    
}
