//
//  GoogleBannerAdapter.swift
//  TappxFrameworkDemo
//
//  Created by David Alarcon on 25/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import TappxFramework

class GoogleBannerAdapter: NSObject, TappxAdapter {

    var adapterId: String = "com.tappx.sdk.android.mobileads.Google.Banner"
    
    func adapt(step: TappxMediatorStep, completion: (NSError?) -> ()) {
        print("I can process ... (\(adapterId))")
        let msg = "Banner Error"
        let info = [NSLocalizedDescriptionKey: "\(msg)"]
        let _ = NSError(domain: "com.tappx.TappxFramework", code: -102, userInfo: info)
        completion(.None)
    }
    
}
