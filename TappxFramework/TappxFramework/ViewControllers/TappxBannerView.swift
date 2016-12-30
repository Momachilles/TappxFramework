//
//  TappxBannerView.swift
//  TappxFramework
//
//  Created by David Alarcon on 16/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit
import JavaScriptCore

protocol TappxBannerViewDelegate: class {
    func tappxBannerviewDidPress(bannerView view: TappxBannerView)
}

class TappxBannerView: UIView {
    @IBOutlet weak var bannerWebView: UIWebView! {
        didSet {
            self.bannerWebView.scrollView.scrollEnabled = false
            self.bannerWebView.scrollView.bounces = false
            self.bannerWebView.layer.borderColor = UIColor.greenColor().CGColor
            self.bannerWebView.layer.borderWidth = 2.0
            self.bannerWebView.allowsInlineMediaPlayback = true
            self.bannerWebView.mediaPlaybackRequiresUserAction = false
        }
    }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    weak var delegate: TappxBannerViewDelegate?
    weak var webViewDelegate: UIWebViewDelegate? {
        didSet {
            self.bannerWebView.delegate = self.webViewDelegate
        }
    }
    
    var isViewable : Bool = false {
        didSet{
            if(isViewable != oldValue)
            {
                self.fireViewableChangeEvent()
            }
        }
    }
    
    var stateVar : String = "loading" {
        didSet{
            self.fireStateChangeEvent()
        }
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer { [unowned self] tap in
            self.delegate?.tappxBannerviewDidPress(bannerView: self)
        }
        
        tap.delegate = self
        
        self.addGestureRecognizer(tap)
        
        initMraid()
    }
    
    // MARK: load ads
    func loadAd(banner: String) {
        
        stateVar = "loading"
        
        //guard let url: URL = URL(string: "http://") else { return }
        let bundle = NSBundle(forClass: self.dynamicType)
        if let baseUrl = bundle.URLForResource("mraid", withExtension: "js")
        {
            self.bannerWebView.loadHTMLString(banner, baseURL: baseUrl)
        }
        else
        {
            self.bannerWebView.loadHTMLString(banner, baseURL: .None)
        }
    }
    
    // mraid
    
    func initMraid()
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        if let path = bundle.pathForResource("mraid", ofType: "js")
        {
            do {
                let mraidData = try String(contentsOfFile: path)
                self.injectJS(mraidData)
            }
            catch{}
        }
    }
    
    func injectJS(javascript : String)
    {
        let _ = self.bannerWebView.stringByEvaluatingJavaScriptFromString(javascript)
        
    }
    
    func setSupportsAll()
    {
        self.injectJS("mraid.setSupports('sms','true');")
        self.injectJS("mraid.setSupports('tel','true');")
        self.injectJS("mraid.setSupports('calendar','true');")
        self.injectJS("mraid.setSupports('storePicture','true');")
        self.injectJS("mraid.setSupports('inlineVideo','true');")
    }
    
    // mraid firing events
    
    func fireErrorEventWithAction(action : String, message : String)
    {
        self.injectJS("mraid.fireErrorEvent('" + message + "', '" + action + "');")
    }
    
    func fireReadyEvent()
    {
        self.injectJS("mraid.fireReadyEvent();")
    }
    
    func fireStateChangeEvent()
    {
        self.injectJS("mraid.fireStateChangeEvent('" + stateVar + "');")
    }
    
    func fireViewableChangeEvent()
    {
        if(self.isViewable)
        {
            self.injectJS("mraid.fireViewableChangeEvent(true);")
        }
        else
        {
            self.injectJS("mraid.fireViewableChangeEvent(false);")
        }
    }
}

extension TappxBannerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
