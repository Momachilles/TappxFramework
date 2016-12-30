//
//  TestAdapter.swift
//  TappxFrameworkDemo
//
//  Created by David Alarcon on 30/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit
import TappxFramework

class TestAdapter: NSObject, TappxAdapter {

    var adapterId = "Adapter"
    
    func adapt(step: TappxMediatorStep, completion: (NSError?) -> ()) {
        print("Adapring ...")
    }
}
