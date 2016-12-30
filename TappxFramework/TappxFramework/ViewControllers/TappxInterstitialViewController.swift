//
//  TappxInterstitialViewController.swift
//  TappxFramework
//
//  Created by David Alarcon on 19/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

private var kvoContext: UInt8 = 1

@objc public protocol TappxInterstitialViewControllerProtocol {
    func tappxInterstitialViewControllerDidFinishLoad(viewController vc: TappxInterstitialViewController)
    func tappxInterstitialViewControllerDidPress(viewController vc: TappxInterstitialViewController)
    func tappxInterstitialViewControllerDidClose(viewController vc: TappxInterstitialViewController)
    @objc optional func tappxInterstitialViewControllerDidFail(viewController vc: TappxInterstitialViewController, error: NSError)
    func tappxInterstitialViewControllerDidAppear(viewController vc: TappxInterstitialViewController)
}

public class TappxInterstitialViewController: UIViewController {
    
    private var settings: TappxSettings = TappxSettings()
    var delegate: TappxInterstitialViewControllerProtocol?
    lazy var dataSource = DataSource()
    var mraidParser = TappxMRAIDParser()
    private var isObserver = false
    var interstitial: TappxInterstitial?
    private var timer: NSTimer?
    private var secondsLeft: NSTimeInterval = 0
    
    weak var mraidServiceDelegate: TappxMRAIDServiceDelegate?
    
    var mraidUseCustomClose : Bool = false
    
    public override func loadView() {
        let v: TappxInterstitialView = TappxInterstitialView.fromNib()
        v.delegate = self
        v.webViewDelegate = self
        self.view = v
        //Fill with the ad information
        self.updateInterstitialView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWentToBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWentToForeground), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func applicationWentToForeground()
    {
        if let v = self.view as? TappxInterstitialView
        {
            v.isViewable = true
        }
    }
    
    func applicationWentToBackground()
    {
        if let v = self.view as? TappxInterstitialView
        {
            v.isViewable = false
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.tappxInterstitialViewControllerDidAppear(viewController: self)
        
        if let v = self.view as? TappxInterstitialView
        {
            v.isViewable = true
        }
        
        // subscrive
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let v = self.view as? TappxInterstitialView
        {
            v.isViewable = false
        }
    }
    
//    override public func view

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.timer?.invalidate()
        if #available(iOS 8.0, *) {
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
            
            coordinator.animateAlongsideTransition({ _ in
                (self.view as? TappxInterstitialView)?.interstitialWebView.hidden = true
                (self.view as? TappxInterstitialView)?.closeButton.hidden = true
            }) { _ in
                self.dataSource.tappxInterstitial(with: self.settings)
            }
            
        } else { // Rotate in ios 7. Not now, but maybe to fullfil in the future
            // Fallback on earlier versions
            //(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
        }
        
    }
    
    ///Custom Init
    public convenience init(with settings: TappxSettings? = .None, delegate: TappxInterstitialViewControllerProtocol? = .None) {
        self.init(nibName: nil, bundle: nil)
        _ = settings.map    { self.settings = $0    }
        _ = delegate.map    { self.delegate = $0    }
        
        // add tappx observers
        self.dataSource.addObserver(self, forKeyPath: "interstitial", options: [.New], context: &kvoContext)
        self.dataSource.addObserver(self, forKeyPath: "error", options: [.New], context: &kvoContext)
        self.isObserver = true

        // load advdertisement (get HTML before adding the view to hierarchy)
        self.dataSource.tappxInterstitial(with: self.settings)
    }
    
    deinit {
        print("Deinit TappxInterstitialViewController ...")
        if self.isObserver {
            self.dataSource.removeObserver(self, forKeyPath: "interstitial", context: &kvoContext)
            self.dataSource.removeObserver(self, forKeyPath: "error", context: &kvoContext)
            self.isObserver = false
        }
        self.timer?.invalidate()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == context {
            if keyPath == "interstitial" {
                guard let interstitial = change?[NSKeyValueChangeNewKey] as? TappxInterstitial else { return }
                print(interstitial)
                print("Dimensions: \(interstitial.headers.xwidth.value)x\(interstitial.headers.xheight.value)")
                self.interstitial = interstitial
                self.delegate?.tappxInterstitialViewControllerDidFinishLoad(viewController: self)
                
                //If we call the ad again when our view is already in the view hierarchy, otherwise don't do anything else
                if self.isViewLoaded() == true {
                    self.updateInterstitialView()
                }
            }
            
            if keyPath == "error" {
                guard let error = change?[NSKeyValueChangeNewKey] as? NSError else { return }
                self.delegate?.tappxInterstitialViewControllerDidFail?(viewController: self, error: error)
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func updateInterstitialView() {
        guard
            let interstitial = self.interstitial,
            let sheight = interstitial.headers.xheight.value as? String,
            let height = Double(sheight),
            let swidth = interstitial.headers.xwidth.value as? String,
            let width = Double(swidth),
            let view = self.view as? TappxInterstitialView
            else { return }
        
        self.timer?.invalidate()
        view.loadAd(interstitial.html)
        view.frame = UIScreen.mainScreen().bounds
        view.widthInterstitialWebViewConstraint.constant = CGFloat(width)
        view.heightInterstitialWebViewConstraint.constant = CGFloat(height)
        
        view.interstitialWebView.hidden = false
        view.closeButton.hidden = false
        
        let str = String(interstitial.headers.xfst.value)
        let i: Double = (Double(str) ?? 0.0) / 1000.0
        self.secondsLeft = i
        view.closeButton.number = UInt(i) // String(describing: interstitial.headers.xfst.value) as? CGFloat ?? 0
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.secondsLeft, target: self, selector: #selector(updateCloseButton), userInfo: .None, repeats: true)
        
    }
    
    @objc func updateCloseButton() {
        print("Seconds left: \(self.secondsLeft)")
        let seconds = max(self.secondsLeft - 1, 0)
        if seconds == 0 {
            self.timer?.invalidate()
        }
        
        guard let view = self.view as? TappxInterstitialView else { return }
        view.closeButton.number = UInt(seconds)
        self.secondsLeft = seconds
    }
    
    public func html() -> String {
        return self.interstitial?.html ?? ""
    }

}

extension TappxInterstitialViewController: UIWebViewDelegate {
    
    public func webView(webView: UIWebView, shouldStartLoadWith request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // Determine if we want the system to handle it.
        guard let url = request.URL else { return false }
        
        if url.scheme == "tappx" { //Scheme from tappx. Ignore for now
            return false
        }
        
        if navigationType == .LinkClicked {
            
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
                return false
            }
            
        }
        
        // mraid
        if url.scheme == "mraid"
        {
            self.processMraidUrl(url)
            
        }
        return true
        
    }
    
    // webview
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        print("Page loaded: \(webView.request?.URL?.absoluteString)")
        
        self.initMraidWebView()
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if let err = error {
            if err.code == NSURLErrorCancelled { return }
            if err.code == 102 && err.domain == "WebKitErrorDomain" { return }
            
            print("Page error: \(webView.request?.URL?.absoluteString), \(err)")
        }
        
        
        if let url = webView.request?.URL
        {
            if url.scheme == "mraid"
            {
                self.processMraidUrl(url)
            }
        }
    }
    
    // MRAID

    func initMraidWebView()
    {
        if let v = self.view as? TappxInterstitialView
        {
            v.injectJS("mraid.setPlacementType('interstitial');")
            v.setSupportsAll()
            v.stateVar = "default"
            v.fireReadyEvent()
            v.fireViewableChangeEvent()
            
            self.setScreenSize()
        }
    }
    
    func setScreenSize()
    {
        var screenSize = UIScreen.mainScreen().bounds.size
        
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation)
        
        if #available(iOS 8, *) {
        } else {
            if isLandscape { screenSize = CGSize(width: screenSize.height, height: screenSize.width) }
        }
        
        if let v = self.view as? TappxBannerView
        {
            v.injectJS("mraid.setScreenSize(\(screenSize.width),\(screenSize.height));")
            v.injectJS("mraid.setDefaultPosition(0,0,\(screenSize.width),\(screenSize.height));")
        }
    }
    
    func fireSizeChangeEvent()
    {
        if let v = self.view as? TappxBannerView
        {
            if let originInRootView = v.window?.rootViewController?.view.convertPoint(CGPoint.zero, toView: v)
            {
                let x = originInRootView.x
                let y = originInRootView.y
                let width = v.frame.size.width
                let height = v.frame.size.height
                
                let isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation)
                
                if #available(iOS 8, *) {
                } else {
                    if isLandscape {
                        v.injectJS("mraid.setCurrentPosition(\(x),\(y),\(height),\(width));")
                    } else {
                        v.injectJS("mraid.setCurrentPosition(\(x),\(y),\(width),\(height));")
                    }
                }
            }
        }
    }
    
    func processMraidUrl(url : NSURL)
    {
        let commandDict = mraidParser.parseUrl(url)
        
        if let command = commandDict["command"] as? String
        {
            if let paramDict = commandDict["paramDict"] as? Dictionary<String, Any>
            {
                if(command == "createCalendarEvent")
                {
                    self.createCalendarEvent(paramDict)
                }
                if(command == "close")
                {
                    self.close()
                }
                if(command == "expand")
                {
                    self.expand(paramDict)
                }
                if(command == "open")
                {
                    self.open(paramDict)
                }
                if(command == "playVideo")
                {
                    self.playVideo(paramDict)
                }
                if(command == "resize")
                {
                    self.resize()
                }
                if(command == "setOrientationProperties")
                {
                    self.setOrientationProperties(paramDict)
                }
                if(command == "setResizeProperties")
                {
                    self.setResizeProperties(paramDict)
                }
                if(command == "storePicture")
                {
                    self.storePicture(paramDict)
                }
                if(command == "useCustomClose")
                {
                    self.useCustomClose(paramDict)
                }
                
            }
        }
    }
    
    //  MRAID services
    
    public func createCalendarEvent(properties : Dictionary<String, Any>)
    {
        if let urlString = properties["eventJSON"] as? String
        {
            let url = urlString.stringByRemovingPercentEncoding
            mraidServiceDelegate?.createCalendarEvent?(url!)
        }
    }
    
    public func close()
    {
        if(self.mraidUseCustomClose)
        {
            self.delegate?.tappxInterstitialViewControllerDidClose(viewController: self)
        }
    }
    
    public func expand(properties : Dictionary<String, Any>)
    {
        
    }
    
    public func open(properties : Dictionary<String, Any>)
    {
        if let urlString = properties["url"] as? String
        {
            let url = urlString.stringByRemovingPercentEncoding
            mraidServiceDelegate?.open?(url!)
        }
    }
    
    public func playVideo(properties : Dictionary<String, Any>)
    {
        if let urlString = properties["url"] as? String
        {
            let url = urlString.stringByRemovingPercentEncoding
            mraidServiceDelegate?.playVideo?(url!)
        }
    }
    
    public func resize()
    {
        
    }
    
    public func setOrientationProperties(properties : Dictionary<String, Any>)
    {
        
    }
    
    public func setResizeProperties(properties : Dictionary<String, Any>)
    {
        
    }
    
    public func storePicture(properties : Dictionary<String, Any>)
    {
        if let urlString = properties["url"] as? String
        {
            let url = urlString.stringByRemovingPercentEncoding
            mraidServiceDelegate?.storePicture?(url!)
        }
    }
    
    public func useCustomClose(properties : Dictionary<String, Any>)
    {
        if let useCustom = properties["useCustomClose"] as? String
        {
            if(useCustom == "true")
            {
                self.mraidUseCustomClose = true
            }
            else
            {
                self.mraidUseCustomClose = false
            }
        }
    }
}

extension TappxInterstitialViewController: TappxInterstitialViewDelegate {
    
    func tappxInterstitialViewDidPress(interstitialView view: TappxInterstitialView) {
        self.delegate?.tappxInterstitialViewControllerDidPress(viewController: self)
        //Click event
        guard
            let value = self.interstitial?.headers.xclktrack.value as? String,
            let url = NSURL(string: value)
        else { return }
        self.dataSource.tappxEvent(with: url)
    }
    
    func tappxInterstitialViewDidClose(interstitialView view: TappxInterstitialView) {
        self.delegate?.tappxInterstitialViewControllerDidClose(viewController: self)
    }
    
}
