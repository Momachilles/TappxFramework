//
//  TappxRequestInfo.swift
//  TappxFramework
//
//  Created by David Alarcon on 22/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

struct TappxRequestInfo {
    var parameters: TappxQueryStringParameters = TappxQueryStringParameters()
    var body: TappxPostBodyParameters = TappxPostBodyParameters.defaultBodyParameters
    
    func update(from settings: TappxSettings) {
        var body = self.body
        
        if let keywords = settings.keywords {
            body.okw = keywords.joinWithSeparator(",")
        }
        
        body.sdkt = settings.sdkType
        
        if let mediator = settings.mediator {
            body.mediator = mediator
        }
        
        if let birth = settings.yearOfBirth {
            body.oyob = Int(birth) ?? 0
        }
        
        if let age = settings.age {
            body.oage = Int(age) ?? 0
        }
        
        if let gender = settings.gender {
            body.ogender = gender.rawValue
        }
        
        if let marital = settings.marital {
            body.omarital = marital.rawValue
        }
    }
}
