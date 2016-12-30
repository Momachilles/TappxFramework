//
//  TappxInterstitialView.swift
//  TappxFramework
//
//  Created by David Alarcon on 19/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

protocol TappxInterstitialViewDelegate: class {
    func tappxInterstitialViewDidPress(interstitialView view: TappxInterstitialView)
    func tappxInterstitialViewDidClose(interstitialView view: TappxInterstitialView)
}

class TappxInterstitialView: UIView {
    @IBOutlet weak var interstitialWebView: UIWebView! {
        didSet {
            self.interstitialWebView.scrollView.scrollEnabled = false
            self.interstitialWebView.scrollView.bounces = false
            self.interstitialWebView.allowsInlineMediaPlayback = true
            self.interstitialWebView.mediaPlaybackRequiresUserAction = false
        }
    }
    @IBOutlet weak var heightInterstitialWebViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthInterstitialWebViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: TappxCloseButton!
    
    @IBAction func closeButtonDidPress(sender: AnyObject) {
        self.delegate?.tappxInterstitialViewDidClose(interstitialView: self)
    }
    
    var stateVar : String = "loading" {
        didSet{
            self.fireStateChangeEvent()
        }
    }
    
    
    /*
    @IBOutlet weak var closeLabel: UILabel! {
        didSet {
            self.closeLabel.layer.cornerRadius = self.closeLabel.frame.height / 2
            self.closeLabel.layer.borderWidth = 1.0
            self.closeLabel.layer.borderColor = UIColor.white.cgColor
            self.closeLabel.layer.masksToBounds = true
        }
    }*/
    
    weak var delegate: TappxInterstitialViewDelegate?
    weak var webViewDelegate: UIWebViewDelegate? {
        didSet {
            self.interstitialWebView.delegate = self.webViewDelegate
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
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer { [unowned self] tap in
            self.delegate?.tappxInterstitialViewDidPress(interstitialView: self)
        }
        
        tap.delegate = self
        
        self.interstitialWebView.addGestureRecognizer(tap)
        
        //init mraid
        
        initMraid()
        
    }
    
    // MARK: load ads
    func loadAd(interstitial: String) {
        
        stateVar = "loading"
        
        //guard let url: URL = URL(string: "http://") else { return }
        let bundle = NSBundle(forClass: self.dynamicType)
        
        if let baseUrl = bundle.URLForResource("mraid", withExtension: "js")
        {
            self.interstitialWebView.loadHTMLString(interstitial, baseURL: baseUrl)
        }
        else
        {
            self.interstitialWebView.loadHTMLString(interstitial, baseURL: .None)
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
        let _ = self.interstitialWebView.stringByEvaluatingJavaScriptFromString(javascript)
        
    }
    
    // mraid receiving events
    
    
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

extension TappxInterstitialView: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
