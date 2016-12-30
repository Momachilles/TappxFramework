//
//  TappxMRAIDParser.swift
//  TappxFramework
//
//  Created by Sara Victor Fernandez on 26/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

class TappxMRAIDParser: NSObject {
    
    
//    func parseURL(url: NSURL) -> [String: Any] {
//        var dict: [String: Any] = [:]
//        let paramString = url.parameterString
//        
//        let keyValues = paramString?.componentsSeparatedByString("&")
//        if keyValues?.count > 0 {
//            for pair in keyValues! {
//                let kv = pair.componentsSeparatedByString("=")
//                if kv.count > 1 {
//                    dict.updateValue(kv[1], forKey: kv[0])
//                }
//            }
//            
//        }
//        
//        return dict
//        
//    }

    func parseUrl(url : NSURL) -> Dictionary<String,Any>
    {
        var dict = Dictionary<String,Any>()
        
        /*
         The command is a URL string that looks like this:
         
         mraid://command?param1=val1&param2=val2&...
         
         We need to parse out the command, create a dictionary of the paramters and their associated values,
         and then send an appropriate message back to the MRAIDView to run the command.
         */
        
        // Remove mraid:// prefix.
        let commandUrl = url.absoluteString
        let index = commandUrl.startIndex.advancedBy(8)
        let s = commandUrl.substringFromIndex(index)
        
        var command : String?
        var params = Dictionary<String,String>()
        
        // Check for parameters, parse them if found
        if let range = s.rangeOfString("?")
        {
            command = s.substringToIndex(range.startIndex)
            
            let paramStr = s.substringFromIndex(range.endIndex);
            
            let paramsArray = paramStr.componentsSeparatedByString("&")
            
            for param in paramsArray
            {
                let paramString = param
                
                if let paramRange = paramString.rangeOfString("=")
                {
                    let key = paramString.substringToIndex(paramRange.startIndex)
                    let value = paramString.substringFromIndex(paramRange.endIndex)
                    params[key] = value
                }
                
            }
        }
        else
        {
            command = s
        }
        
        if !self.isValidCommand(command!) || !self.checkParamsForCommand(command!, params:params)
        {
            return dict
        }
        
        dict["paramDict"] = params
        dict["command"] = command
        return dict
    }

    func isValidCommand(command : String) -> Bool
    {
        return command == "createCalendarEvent" ||
                command == "close" ||
                command == "expand" ||
                command == "open" ||
                command == "playVideo" ||
                command == "resize" ||
                command == "setOrientationProperties" ||
                command == "setResizeProperties" ||
                command == "storePicture" ||
                command == "useCustomClose"
    }
    
    func checkParamsForCommand(command : String, params : Dictionary<String, String>) -> Bool
    {
        if(command == "createCalendarEvent")
        {
            return params["eventJSON"] != nil;
        }
        if(command == "open" || command == "playVideo" || command == "storePicture")
        {
            return params["url"] != nil
        }
        if(command == "setOrientationProperties")
        {
            return params["allowOrientationChange"] != nil && params["forceOrientation"] != nil
        }
        if(command == "setResizeProperties")
        {
            return params["width"] != nil &&
                    params["height"] != nil &&
                    params["offsetX"] != nil &&
                    params["offsetY"] != nil &&
                    params["customClosePosition"] != nil &&
                    params["allowOffscreen"] != nil
        }
        if(command == "useCustomClose")
        {
            return params["useCustomClose"] != nil
        }
        return true
    }
    
}
