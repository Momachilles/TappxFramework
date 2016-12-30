//
//  Banner.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

protocol TappxAdvertisement {
    var html: String { get set }
    var headers: ResponseHeaders { get set }
    var type: TappxResponseType { get set }
    //init()
    init(with html: String, headers: ResponseHeaders, type: TappxResponseType)
}

//TODO: Figure out how to do it throuh protocol directly, no from tappxbanner
/*
extension TappxAdvertisement {
    
    var data: String {
        return self.html
    }
    
    var headers: [ResponseHeaders] {
        return self.headers
    }
    
    var types: [TappxResponseType] {
        return self.types
    }
    
    init(with html: String, headers: ResponseHeaders, types: [TappxResponseType]) {
        self.init()
        self.html = html
        self.headers = headers
        self.types = types
        print("Data: \(self.data)")
    }
    
} */

class TappxBanner: NSObject, TappxAdvertisement {
    
    var html: String
    var headers: ResponseHeaders
    var type: TappxResponseType
    
    required init(with html: String, headers: ResponseHeaders, type: TappxResponseType) {
        self.html = html
        self.headers = headers
        self.type = type
        super.init()
    }
    
    
}

extension TappxBanner {
    override public var debugDescription: String {
        let hex = "0x" + String(self.hashValue, radix: 16)
        return "Banner: (\(hex)) \"\(self.html)\"\n\(self.headers)"
    }
}

extension TappxBanner {
    override public var description: String {
        let hex = "0x" + String(self.hashValue, radix: 16)
        return "Banner: (\(hex)) \"\(self.html)\"\n\(self.headers)"
    }
}


