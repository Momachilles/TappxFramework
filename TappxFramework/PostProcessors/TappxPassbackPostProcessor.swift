//
//  PassbackPostProcessor.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

class TappxPassbackPostProcessor:  NSObject, TappxPostProcessor {
    
    let failString = "tappx://noFillAd"
    
    var type: TappxResponseType {
        return .passback
    }
    
    func postProcess(data: String) -> AnyObject? {
        
        let urls = data.extractURLs()
        var ok: Bool = true
        
        for url in urls {
            
            if url.absoluteString.rangeOfString(failString) != .None {
                ok = false
                break
            }
        }
        
        return ok as AnyObject
        
    }
    
    

}
