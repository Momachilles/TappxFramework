//
//  Settings.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

struct TappxSettingsConstants {
    static var tappxSettingsAssociationKey = "TappxSettings"
}

public final class TappxSettings {
    var sdkType: String = "3.0.0"
    public var mediator: String?
    public var keywords: [String]?
    public var yearOfBirth: String?
    public var age: String?
    public var gender: Gender?
    public var marital: Marital?
    
    

}


protocol TappxSetting {
    var settings: TappxSettings { get }
    func update(settings: TappxSettings)
}

/*extension TappxSetting {
    
    var settings: TappxSettings {
        get { return (objc_getAssociatedObject(self, &TappxSettingsConstants.tappxSettingsAssociationKey) as? Associated<TappxSettings>)?.associatedValue() ?? TappxSettings() }
        ////        set { objc_setAssociatedObject(self, &TappxSettingsConstantss.tappxSettingsAssociationKey, newValue.map { Associated<Settings>($0) }, .OBJC_ASSOCIATION_RETAIN) }
    }

    func update(settings: TappxSettings) {
        objc_setAssociatedObject(self, &TappxSettingsConstants.tappxSettingsAssociationKey, Associated<TappxSettings>(settings), .OBJC_ASSOCIATION_RETAIN)
    }
}*/

//extension TappxSettings: NSCoding {
//    
//    convenience public init?(coder aDecoder: NSCoder) {
//        guard
//            let sdkType = aDecoder.decodeObjectForKey("sdkType") as? String,
//            let mediator = aDecoder.decodeObjectForKey("mediator") as? String,
//            let keywords = aDecoder.decodeObjectForKey("keywords") as? [String],
//            let yearOfBirth = aDecoder.decodeObjectForKey("yearOfBirth") as? String,
//            let age = aDecoder.decodeObjectForKey("age") as? String,
//        let gender =  Gender(rawValue: ) aDecoder.decodeObjectForKey("gender") as? Gender,
//            let marital = aDecoder.decodeObjectForKey("marital") as? Marital
//            else { return nil }
//        
//        self.init()
//
//        self.sdkType = sdkType
//        self.mediator = mediator
//        self.keywords = keywords
//        self.yearOfBirth = yearOfBirth
//        self.age = age
//        self.gender = gender
//        self.marital = marital
//
//    }
//    
//    public func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(sdkType, forKey: "sdkType")
//        aCoder.encodeObject(mediator, forKey: "mediator")
//        aCoder.encodeObject(keywords, forKey: "keywords")
//        aCoder.encodeObject(yearOfBirth, forKey: "yearOfBirth")
//        aCoder.encodeObject(age, forKey: "age")
//        aCoder.encodeObject(gender, forKey: "gender")
//        aCoder.encodeObject(marital, forKey: "marital")
//    }
//
//}
