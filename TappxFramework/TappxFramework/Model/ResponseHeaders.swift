//
//  ResponseHeaders.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

struct ResponseHeaders {
    
    typealias TappxHeader = (header: String, value: AnyObject)
    
    ///Defines which kind of response has been received
    var xcontent: TappxHeader = ("x-content", "")
    
    ///Passed this time (seconds) new Banner will be requested (as if developer has called “loadAd()” but maintaining the AD until new AD has received.
    ///If no AD has been received we will try again in x- refreshad seconds. (For interstitials this will only affects when TTL has been passed).
    var xrefreshad: TappxHeader = ("x-refreshad", "")
    
    ///Defines AD Time-To-Live (in seconds), passed this time, new request will be done as if developer has call “loadAd()”, The AD will be maintained until
    ///new AD has been received. If no AD has been received we will do a new request if x-refreshad has been set.
    var xttl: TappxHeader = ("x-ttl", "")
    
    ///Defines is AD can be scrolled inside of TappxView, used for show large Ads inside of an interstitial
    var xscrollable: TappxHeader = ("x-scrollable", "")
    
    ///AD Width: For center AD inside of View/Activity. For Mediator class, this will be the Size of the AD choose by the AdServer, maybe in other
    ///Mediation class we can receive other Size that will be override this one, if not we will use this one.
    var xwidth: TappxHeader = ("x-width", "")
    
    ///AD Height: Same than x-width but for Height
    var xheight: TappxHeader = ("x-height", "")
    
    ///Defines Force-Show-Time, close button only can be showed/clicked passed this time (in seconds)
    var xfst: TappxHeader = ("x-fst", "")
    
    ///(url). If this attribute has been defined, the url must to be called if an AD has been received. This url will return a 1x1 pixel, if something has failed
    ///we will try until we receive HTTP 200.
    var xdeltrack: TappxHeader = ("x-deltrack", "")
    
    ///(url). If this attribute has been defined, the url must to be called if an AD has been showed. This url will return a 1x1 pixel, if something has failed
    ///we will try until we receive HTTP 200.
    var ximptrack: TappxHeader = ("x-imptrack", "")
    
    ///(url). If this attribute has been defined, the url must to be called if an AD has been clicked. This url will return a 1x1 pixel, if something has failed
    ///we will try until we receive HTTP 200.
    var xclktrack: TappxHeader = ("x-clktrack", "")
    
    ///Defines is Activity should be showed as Overlay if it is possible (has more space than the ad). F.ex: when 300x250 has been returned for 320x480).
    ///Default: 0
    let xoverlay: TappxHeader = ("x-overlay", "")
    
    ///Defines if the Ad has to be showed with any animation. By default without animation. Animation will be defined later.
    ///Default: none (or not defined)
    ///Other: random (sdk will choose one of existing animations randomly [except none])
    let xanimation: TappxHeader = ("x-animation", "")
    
    ///Error Reason
    var xerrorreason: TappxHeader = ("x-error-reason", "")
    
    ///Balancer
    let xbalancer: TappxHeader = ("X-Balancer", "")
    
    ///App Server
    let xappserver: TappxHeader = ("X-App-Server", "")
    
    
    init(from headers: [String: Any]) {
        self.xcontent.value = (headers[self.xcontent.header ] as? String) ?? ""
        self.xrefreshad.value = (headers[self.xrefreshad.header ] as? String) ?? ""
        self.xttl.value = (headers[self.xttl.header ] as? String) ?? ""
        self.xscrollable.value = (headers[self.xscrollable.header ] as? String) ?? ""
        self.xwidth.value = (headers[self.xwidth.header ] as? String) ?? ""
        self.xheight.value = (headers[self.xheight.header ] as? String) ?? ""
        self.xfst.value = (headers[self.xfst.header ] as? String) ?? ""
        self.xdeltrack.value = (headers[self.xdeltrack.header ] as? String) ?? ""
        self.ximptrack.value = (headers[self.ximptrack.header ] as? String) ?? ""
        self.xclktrack.value = (headers[self.xclktrack.header ] as? String) ?? ""
        self.xerrorreason.value = (headers[self.xerrorreason.header ] as? String) ?? ""
    }
    
}
