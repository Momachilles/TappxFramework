//
//  PostProcessor.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

protocol TappxPostProcessor {
    var type:TappxResponseType { get }
    func postProcess(data: String) -> AnyObject?
}
