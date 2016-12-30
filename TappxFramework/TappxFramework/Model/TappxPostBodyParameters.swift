//
//  PostBodyParameters.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

typealias BodyParameters = [String: Any]

internal protocol PostBodyParameterSet {
    
    ///Optional Keywords
    var okw: String { get set }
    ///SDK Version
    var sdkv: String { get set }
    ///SDK Type [Could be set by developer to create news SDK for other frameworks (PhoneGAP, Unity, etc.)]
    ///Default: Native
    var sdkt: String { get set }
    ///When we're called from any mediation system, in mediation SDK has be able to set their name, for example: admob, mopub, heyzap, fyber, etc.
    ///Default: (empty)
    var mediator: String { get set }
    ///GooglePlayServices compiled version
    var gpscv: Int { get set }
    ///GooglePlayServices Lib Version (version installed in device)
    var gpslv: Int { get set }
    ///MRAID Supported Version
    var mraid: Float { get set }
    ///IDFA
    var aid: String { get set }
    ///AdvertisingID Alternative MD5
    var aida: String { get set }
    ///Tracking Limited (0=No Limited, 1=Limited)
    var aidl: Bool { get set }
    ///Device Manufacturer Name
    var dmn: String { get set }
    ///Device Model
    var dmo: String { get set }
    ///Device Model ProductName
    var dmp: String { get set }
    ///Device Operating System
    var dos: String { get set }
    ///Device Operating System Version
    var dov: String { get set }
    ///Device Screen Width (take care device orientation)
    var dsw: Int { get set }
    ///Device Screen Height (take care device orientation)
    var dsh: Int { get set }
    ///Device Screen Density
    var dsd: Float { get set }
    ///Device User Agent
    var dua: String { get set }
    ///Device Configured Language
    var dln: String { get set }
    ///Device Connection Type: 2G, 3G, UMTS, HDSPA, WIFI, etc...
    var dct: String { get set }
    ///SIM Operator Code (MCC + MNC)
    var soc: Int { get set }
    ///SIM Operator Name
    var son: String { get set }
    ///SIM Operator Country (ISO 3166-1 alpha-2)
    var scc: String { get set }
    ///SIM Operator Code (MCC + MNC)
    var noc: Int { get set }
    ///SIM Operator Name
    var non: String { get set }
    ///Network Operator Country(ISO3166-1 alpha-2)
    var ncc: String { get set }
    ///Application Language
    var aln: String { get set }
    ///Application Bundle/packagename
    var ab: String { get set }
    ///Application Name
    var an: String { get set }
    ///Geo coordinates (latitude, longitude) :: We need to add GEO data only if the APP has Permissions to get this info!
    var geo: String { get set }
    ///Estimated accuracy of this location, in meters
    var ga: Int { get set }
    ///Milliseconds since location was updated.
    var gf: Int { get set }
    ///Time zone offset. e.g. Pacific Standard Time
    var gz: String { get set }
    ///Optional, Year Of Birth (4-digit integer)
    ///Default: (empty)
    var oyob: Int { get set }
    ///Optional, User Age
    var oage: Int { get set }
    ///Optional: Gender (M=male, F=female, O=Other)
    ///Default: (empty)
    var ogender: String { get set }
    ///Optional, Marital (S=Single, L=LivingCommon, M=Married, D=Divorced, W=Widowed)
    ///Default: (empty)
    var omarital: String { get set }
    
    func parameters() -> [String: AnyObject]
    
}


internal struct TappxPostBodyParameters: PostBodyParameterSet {

    var okw = "4"
    var sdkv = "3.0.0"
    var sdkt = "native" //By user
    var mediator = ""
    var gpscv = 9452030
    var gpslv = 8301430
    var mraid: Float = 2.0
    var aid = "96bd03b6-defc-4203-83d3-dc1c730801f7"
    var aida = "acc106e89b01a1ef12bd870089e0ed9d"
    var aidl = false
    var dmn = "Samsung"
    var dmo = "GT-i9300"
    var dmp = "Galaxy S3"
    var dos = "android"
    var dov = "6.0.1"
    var dsw = 1080
    var dsh = 1920
    var dsd: Float = 3.0
    var dua =  "Mozilla/5.0 (Linux; Android 5.0.1; en-us; SM-N910V Build/LRX22C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.93 Mobile Safari/537.36"
    var dln = "es-ES"
    var dct = "wifi"
    var soc = 21407
    var son = "Movistar"
    var scc = "ES"
    var noc = 21407
    var non = "Movistar"
    var ncc = "ES"
    var aln = "en-US"
    var ab = "com.tappx.apptest"
    var an = "AppTest for Tappx"
    var geo = ""
    var ga = 0
    var gf = 0
    var gz = "+0000"
    var oyob = 0
    var oage = 0
    var ogender = ""
    var omarital = ""
    
    internal func parameters() -> [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                parameters[label] = child.value as? AnyObject
            }
        }
        
        return parameters
    }
    
    static var defaultBodyParameters: TappxPostBodyParameters = TappxPostBodyParameters()
    
    func json() throws -> NSData {
        let p = self.parameters()
        return try NSJSONSerialization.dataWithJSONObject(p, options: .PrettyPrinted)
    }
    
}
