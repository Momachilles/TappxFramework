//
//  QueryStringParameters.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

protocol QueryParameterSet {
    /// Timestamp in millisencods (epoch format)
    var ts: NSTimeInterval { get set }
    /// Tappx APP Key
    var k: String { get set }
    /// AdType: banner | interstitial
    var at: QueryAdType { get set }
    /// Forced Size (for banners): Used when SMART_BANNER is not configured, ex: 300x250
    var fsz: String? { get set }
    /// Request Test Ads: 0 by default, 1 for test
    var test: UInt { get set }
    
    func urlString() -> String
    
}

public enum QueryAdType: String {
    case banner = "banner"
    case interstitial = "interstitial"
    
    func type() -> String {
        return self.rawValue
    }
}

struct TappxQueryStringParameters: QueryParameterSet {

    var ts: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    var k: String = "pub-mon-android-yo"
    var at: QueryAdType = .banner
    var fsz: String?
    var test: UInt = 0
    
    func urlString() -> String {
        
        var params: [String: String] = [
            "ts"    : "\(ts)",
            "k"     : k,
            "at"    : at.type(),
            "test"  :  "\(test)"
        ]
        
        if let fsz = fsz {
            params["fsz"] = fsz
        }
        
        return params.stringFromHttpParameters()
    }
    
}
