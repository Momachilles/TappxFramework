//
//  AdServerTappxFramework.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 21/10/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import CoreLocation

struct TappxFrameworkConstants {
    static let clientIdKey = "ClientIdKey"
    static var tappxAssociationKey: UInt8 = 0
    static var tappxSettingsAssociationKey = "TappxSettings"
}

// MARK: - Settings Protocol

public enum Gender: String {
    case Male   = "male"
    case Female = "female"
    case Other  = "Other"
}

public enum Marital: String {
    case Single         = "Single"
    case LivingCommon   = "Living Common"
    case Married        = "Married"
    case Divorced       = "Divorced"
    case Widowed        = "Widowed"
}

public enum BannerForcedSize: String {
    case x320y50    = "320x50"
    case x728y90    = "728x90"
    case x300y250   = "300x250"
}

///iPad/iPhone
public enum InterstitialForcedSize: String {
    case x320y480   = "320x480"
    case x480y320   = "480x320"
    case x768y1024  = "768x1024"
    case x1024y768  = "1024x768"
}

public class TappxFramework: NSObject {
    public static let sharedInstance = TappxFramework()
    
    /*
    var requestInfo: TappxRequestInfo = TappxRequestInfo()
    
    public var sdkType = "Native" {
        didSet {
            self.requestInfo.body.sdkt = self.sdkType
        }
    }
    
    public var mediator = "" {
        didSet {
            self.requestInfo.body.mediator = self.mediator
        }
    }
    
    private var tappxSettings: TappxSettings = TappxSettings()
    var loadedAdapters: [TappxAdapter] = []
    let locationManager: TappxLocationManager = TappxLocationManager()
    var lastPosition: (latitude: Double, longitude: Double)?  {
        return self.locationManager.lastPosition
    }*/
    
    ///This prevents others from using the default '()' initializer for this class.
    private override init() {}
    
    public static func initTappx(from clientId: String/*, with settings: TappxSettings = TappxSettings()*/) {
        let framework = TappxFramework.sharedInstance
        framework.clientId = clientId
        //framework.update(settings)
        //framework.locationManager.startLocation()
    }
    
}

// MARK: - Client
extension TappxFramework {
    
    private var db: NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    var clientId: String? {
        get { return self.loadClientId() }
        set { if let value = newValue { self.saveClientId(value) }}
    }
    
    private func saveClientId(value: String) {
        self.db.setValue(value, forKey: TappxFrameworkConstants.clientIdKey)
        self.db.synchronize()
    }
    
    private func loadClientId() -> String? {
        return self.db.stringForKey(TappxFrameworkConstants.clientIdKey)
    }
    
}

// MARK: - Adapters
/*
extension TappxFramework: TappxAdapterContainer {
    
    public func removeAdapter(adapter: TappxAdapter) throws {
        guard let index = self.loadedAdapters.indexOf({ $0.adapterId == adapter.adapterId }) else { throw NSError(domain: "Adapter doesn't exists", code: -10, userInfo: [:]) }
        self.loadedAdapters.removeAtIndex(index)
    }

    public func addAdapter(adapter: TappxAdapter) {
        self.loadedAdapters.append(adapter)
    }

    public func assignAdapters(new adapters: [TappxAdapter]) {
        self.loadedAdapters = adapters
    }
    
    public func adapter(with id: String) -> TappxAdapter? {
        let adapters = self.loadedAdapters.filter { return $0.adapterId == id }
        return (adapters.count > 0) ? adapters[0] : .None
    }
    
    public var adapters: [TappxAdapter] {
        return self.loadedAdapters
    }
    
}

extension TappxFramework: TappxSetting {
    
    var settings: TappxSettings {
        return self.tappxSettings
    }
    
    func update(settings: TappxSettings) {
        self.tappxSettings = settings
        self.requestInfo.update(from: settings)
    }
    
}

extension TappxFramework {
    
    public func mediation(with settings : TappxSettings, type: QueryAdType, completion: (success: Bool, error: NSError?) ->()) {
        
        //TODO: To Uncomment
        //let ds = DataSource()
        //ds.tappxMediation(with: settings, type: type, completion: completion)
        
    }
}
*/


