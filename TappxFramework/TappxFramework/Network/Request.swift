//
//  Request.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

protocol Request {
    var baseURL: NSURL? { get }
    var path: String? { get }
    var parameters: TappxQueryStringParameters { get }
    var body: TappxPostBodyParameters { get }
    
    var request: NSURLRequest? { get }
}

extension Request {
    var path: String { return "" }
    var parameters: TappxQueryStringParameters { return TappxQueryStringParameters() }
    var body: TappxPostBodyParameters { return TappxPostBodyParameters() }
}

