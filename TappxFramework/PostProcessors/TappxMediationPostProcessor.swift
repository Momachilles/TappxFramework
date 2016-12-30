//
//  TappxMediationPostProcessor.swift
//  TappxFramework
//
//  Created by David Alarcon on 22/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

class TappxMediationPostProcessor: NSObject, TappxPostProcessor {
    
    var type: TappxResponseType {
        return .mediation
    }

    //Parse the json to object
    func postProcess(data: String) -> AnyObject? {
        guard let data  = data.dataUsingEncoding(NSUTF8StringEncoding) else { return .None }
        do {
            guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else { return .None }
            return TappxMediator(from: json) as? AnyObject
        } catch {
            return .None
        }
    }
    
}
