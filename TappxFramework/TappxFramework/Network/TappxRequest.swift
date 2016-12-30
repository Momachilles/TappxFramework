//
//  TappxRequest.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import UIKit

struct RequestConstants {
    private static let kProtocol = "https"
    private static let kHostname = "ssp.api.tappx.com"
    static var kBaseURL: String {
        return kProtocol + "://" + kHostname
    }
    static let kAdvertisementPath = "/dev/mon_v1"
    static let kUserAgentKey = "UserAgentKey"
    static let kUserAgentDefault = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Mobile/14A345"
}

enum TappxResponseType {
    case error
    case html
    case passback
    case no_fill
    case mraid1
    case mraid2
    case mediation
}

enum TappxRequest: Request {
    
    case advertisement(TappxQueryStringParameters, TappxPostBodyParameters)
    case event(NSURL)
    
    var baseURL: NSURL? {
        
        switch self {
        case .advertisement:
            return NSURL(string: RequestConstants.kBaseURL)
        case .event(let url):
            return url.baseURL
        }
    }
    
    var parameters: TappxQueryStringParameters {
        switch self {
        case .advertisement(let params, _):
            return params
        case .event:
            return TappxQueryStringParameters()
        }
    }
    
    var body: TappxPostBodyParameters {
        switch self {
        case .advertisement(_, let params):
            return params
        case .event:
            return TappxPostBodyParameters.defaultBodyParameters
        }
    }
        
    
    var path: String? {
        switch self {
            
        case .advertisement:
            guard let url = self.baseURL else { return .None }
            let queryString = self.parameters.urlString()
            return "\(url)\(RequestConstants.kAdvertisementPath)?\(queryString)"
        case .event(let url):
            return url.absoluteString
        }
    }
    
    var type: TappxResponseType {
        guard
            let keyword = UInt(body.okw)
            else { return .error }
        return self.requestType(keyword)
    }
    
    private var userAgent: String {
        
        let db = NSUserDefaults.standardUserDefaults()
        
        if let ua = db.stringForKey(RequestConstants.kUserAgentKey) {
            return ua
        } else {
            if let ua = UIWebView().stringByEvaluatingJavaScriptFromString("navigator.userAgent") {
                db.setValue(ua, forKey: RequestConstants.kUserAgentKey)
                db.synchronize()
                return ua
            } else {
                return RequestConstants.kUserAgentDefault
            }
        }
    }
    
    var request: NSURLRequest? {
        guard let path = self.path else { return .None }
        guard let url = NSURL(string: path) else { return .None }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        //JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        
        switch self {
        case .advertisement:
            do {
                request.HTTPBody = try body.json()
                return request
            } catch {
                return .None
            }
        case .event:
            return request
        }
        
    }
    
    func requestType(keyword: UInt) -> TappxResponseType {
        switch keyword {
        case 0:
            return .error
        case 1:
            return .no_fill
        case 2, 3:
            return .passback
        case 4, 5, 15:
            return .html
        case 6...12, 16:
            return .mraid1
        case 13, 14:
            return .mraid2
        case 17...21:
            return .mediation
        default:
            return .error
        }
    }
    
}
