//
//  TappxMRAIDJavascriptHandler.swift
//  TappxFramework
//
//  Created by Sara Victor Fernandez on 27/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

@objc protocol TappxMRAIDServiceDelegate: class {
    @objc optional  func createCalendarEvent(eventJSON : String);
    @objc optional  func open(urlString : String);
    @objc optional  func playVideo(urlString : String);
    @objc optional  func storePicture(urlString : String);
}
