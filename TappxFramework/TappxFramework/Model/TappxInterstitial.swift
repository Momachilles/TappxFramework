//
//  Interstitial.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

//final class Interstitial: NSObject, TappxAdvertisement {
//    
//    var html: String
//    var headers: ResponseHeaders
//    
//    init(with html: String, headers: ResponseHeaders) {
//        self.html = html
//        self.headers = headers
//        super.init()
//    }
//}

final class TappxInterstitial: TappxBanner {}

extension TappxInterstitial {
    override public var debugDescription: String {
        let hex = "0x" + String(self.hashValue, radix: 16)
        return "Interstitial: (\(hex)) \"\(self.html)\"\n\(self.headers)"
    }
}

extension TappxInterstitial {
    override public var description: String {
        let hex = "0x" + String(self.hashValue, radix: 16)
        return "Interstitial: (\(hex)) \"\(self.html)\"\n\(self.headers)"
    }
}
