//
//  Dictionary+URL.swift
//  Fluttr
//
//  Created by David Alarcon on 11/02/16.
//  Copyright © 2016 David Alarcon. All rights reserved.
//

internal extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    internal func stringFromHttpParameters(encoding: Bool = true) -> String {
        let parameterArray = self.map { (key, value) -> String in
            if encoding {
                let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
                let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
                return "\(percentEscapedKey)=\(percentEscapedValue)"
            } else {
                return "\(key)=\(value)"
            }
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}
