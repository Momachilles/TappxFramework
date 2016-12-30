//
//  DataSource.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import UIKit

class DataSource: NSObject {
    
    dynamic private(set) var banner: TappxBanner? {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    dynamic private(set) var interstitial: TappxInterstitial? {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    dynamic private(set) var isUpdating: Bool = false
    dynamic private(set) var error: NSError? = .None

    private let signaler = TappxSignaler()
    private (set) var lastUpdated: NSDate
    
    private var interstitialSize: InterstitialForcedSize {
    
        let device = UIDevice.currentDevice()
    
        switch (device.userInterfaceIdiom, device.orientation.isPortrait) {
            case (.Phone, true) :
                return .x320y480
            case (.Phone, false):
                return .x480y320
            case (.Pad, true) :
                return .x768y1024
            case (.Pad, false):
                return .x1024y768
            default:
                return .x320y480
        }
    
    }
    
    private var attempsLeft: UInt = 3
    
    override init() {
        self.lastUpdated = NSDate()
        super.init()
    }
    
    deinit {
        print("Deinit DataSource...")
    }
    
    func tappxBanner(with settings: TappxSettings? = .None, size forcedSize: BannerForcedSize? = .None) {
        
        self.isUpdating = true
        
        let newBanner: (TappxBanner) -> () = { [unowned self] banner in
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.banner = banner
                self.isUpdating = false
            }
            
        }
        
        let raiseError: (ErrorType) -> () = { error in
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                let error = NSError(domain: "com.tappx.TappxFramework", code: -101, userInfo: info)
                self.error = error
                self.isUpdating = false
            }
        }
        
        let future = self.signaler.bannerFuture(with: settings, size: forcedSize)
        
        future.start { result in
            switch result {
            case .success(let banner):
                newBanner(banner)
            case .failure(let error):
                raiseError(error)
            }
            
        }
        
    }
    
    func tappxInterstitial(with settings: TappxSettings? = .None) {
        
        self.isUpdating = true
        
        let newInterstitial: (TappxInterstitial) -> () = { [unowned self] interstitial in
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.interstitial = interstitial
                self.isUpdating = false
            }
            
        }
        
        let raiseError: (ErrorType) -> () = { error in
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                let error = NSError(domain: "com.tappx.TappxFramework", code: -101, userInfo: info)
                self.error = error
                self.isUpdating = false
            }
        }
        
        let future = self.signaler.interstitialFuture(with: settings, size: self.interstitialSize)
        
        future.start { result in
            switch result {
            case .success(let interstitial):
                newInterstitial(interstitial)
            case .failure(let error):
                raiseError(error)
            }
            
        }
    }
    
    func tappxEvent(with url: NSURL, completion: ((Bool, ErrorType?) ->())? = .None) {
        
        let future =  self.signaler.eventFuture(with: url)
        future.start { [unowned self] result in
            
            switch result {
            case .success:
                print("Event sent")
                completion?(true, .None)
            case .failure(let error):
                if self.attempsLeft == 0 {
                    self.attempsLeft = 3
                    print("Event error: \(error)")
                    completion?(false, error)
                } else {
                    self.attempsLeft = self.attempsLeft - 1
                    self.tappxEvent(with: url, completion: completion)
                }
            }
            
        }
        
    }
    
    func tappxMediation(with settings: TappxSettings? = .None, type: QueryAdType, completion: (Bool, ErrorType?) ->()) {
        
        self.isUpdating = true
        
        let newMediation: (Bool) -> () = { [unowned self] success in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.isUpdating = false
                completion(success, .None)
            }
            
        }
        
        let raiseError: (ErrorType) -> () = { error in
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                let error = NSError(domain: "com.tappx.TappxFramework", code: -102, userInfo: info)
                self.error = error
                self.isUpdating = false
                completion(false, error)
            }
        }
        
        
        let future =  self.signaler.mediationFuture(with: settings, type: type)
        
        future.start { result in
            switch result {
            case .success(let success):
                newMediation(success)
            case .failure(let error):
                raiseError(error)
            }
            
        }
    }
    
}
