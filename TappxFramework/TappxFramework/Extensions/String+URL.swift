//
//  String+URL.swift
//  Fluttr
//
//  Created by David Alarcon on 11/02/16.
//  Copyright © 2016 David Alarcon. All rights reserved.
//

import Foundation

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        //let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        //return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        return stringByAddingPercentEncodingForFormData(false)
    }
    
    func extractURLs() -> [NSURL] {
        var urls : [NSURL] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            detector.enumerateMatchesInString(self,
                                              options: [],
                                              range: NSMakeRange(0, self.characters.count),
                                              usingBlock: { (result, _, _) in
                                                if let match = result, url = match.URL {
                                                    urls.append(url)
                                                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls
    }
    
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        
        if plusForSpace {
            allowed.addCharactersInString(" ")
        }
        
        var encoded = stringByAddingPercentEncodingWithAllowedCharacters(allowed)
        if plusForSpace {
            encoded = encoded?.stringByReplacingOccurrencesOfString(" ", withString: "+")
        }
        return encoded
    }
}

