//
//  TappxBannerViewController.swift
//  TappxFramework
//
//  Created by David Alarcon on 16/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import UIKit

private var kvoContext: UInt8 = 1

@objc public protocol TappxBannerViewControllerProtocol {
    func tappxBannerViewControllerDidFinishLoad(viewController vc: TappxBannerViewController)
    func tappxBannerViewControllerDidPress(viewController vc: TappxBannerViewController)
    @objc optional func tappxBannerViewControllerDidFail(viewController vc: TappxBannerViewController, error: NSError)
    @objc optional func tappxBannerViewControllerDidClose(viewController vc: TappxBannerViewController)
    
    // mraid
    @objc optional func tappxBannerViewControllerDidCollapse(viewController vc: TappxBannerViewController)
    @objc optional func tappxBannerViewControllerDidExpanse(viewController vc: TappxBannerViewController)
}

public class TappxBannerViewController: UIViewController {

    private var size: BannerForcedSize = .x320y50
    private var settings: TappxSettings = TappxSettings()
    var delegate: TappxBannerViewControllerProtocol?
    lazy var dataSource = DataSource()
    private var isObserver = false
    var banner: TappxBanner?
    
    var mraidParser = TappxMRAIDParser()
    weak var mraidServiceDelegate: TappxMRAIDServiceDelegate?
    var mraidUseCustomClose : Bool = false
    
    ///Custom Init
    public convenience init(with settings: TappxSettings? = .None, size: BannerForcedSize? = .None, delegate: TappxBannerViewControllerProtocol? = .None) {
        self.init(nibName: nil, bundle: nil)
        _ = size.map        { self.size = $0        }
        _ = settings.map    { self.settings = $0    }
        _ = delegate.map    { self.delegate = $0    }
        
        // add tappx observers
        self.dataSource.addObserver(self, forKeyPath: "banner", options: [.New], context: &kvoContext)
        self.dataSource.addObserver(self, forKeyPath: "error", options: [.New], context: &kvoContext)
        self.isObserver = true

        // load advdertisement (get HTML before adding the view to hierarchy)
        self.dataSource.tappxBanner(with: self.settings, size: self.size)
    }
    
    deinit {
        print("Deinit TappxBannerViewController ...")
        if self.isObserver {
            self.dataSource.removeObserver(self, forKeyPath: "banner", context: &kvoContext)
            self.dataSource.removeObserver(self, forKeyPath: "error", context: &kvoContext)
            self.isObserver = false
        }
    }
    
    public override func loadView() {
        let v: TappxBannerView = TappxBannerView.fromNib()
        v.delegate = self
        v.webViewDelegate = self
        self.view = v
        //Fill with the ad information
        self.updateBannerView()
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
        if let v = self.view as? TappxBannerView
        {
            v.isViewable = true
        }
    }
    
    func applicationWentToBackground()
    {
        if let v = self.view as? TappxBannerView
        {
            v.isViewable = false
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let v = self.view as? TappxBannerView
        {
            v.isViewable = true
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let v = self.view as? TappxBannerView
        {
            v.isViewable = true
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == context {
            if keyPath == "banner" {
                guard let banner = change?[NSKeyValueChangeNewKey] as? TappxBanner else { return }
                print(banner)
                print("Dimensions: \(banner.headers.xwidth.value)x\(banner.headers.xheight.value)")
                self.banner = banner
                //                self.delegate?.tappxBannerViewControllerDidFinishLoad(viewController: self)
                //                //If we call the ad again when our view is already in the view hierarchy, otherwise don't do anything else
                //if self.isViewLoaded == true {
                self.updateBannerView()
                //}
            }
            
            if keyPath == "error" {
                guard let error = change?[NSKeyValueChangeNewKey] as? NSError else { return }
                self.delegate?.tappxBannerViewControllerDidFail?(viewController: self, error: error)
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func updateBannerView() {
        guard
            let banner = self.banner,
            let sheight = banner.headers.xheight.value as? String,
            let height = Double(sheight),
            let swidth = banner.headers.xwidth.value as? String,
            let width = Double(swidth)
        else { return }
        
        (self.view as? TappxBannerView)?.loadAd(banner.html)
        self.view.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: width, height: height))
    }
    
    public func html() -> String {
        return self.banner?.html ?? ""
    }

}

extension TappxBannerViewController: UIWebViewDelegate {
    
    public func webView(webView: UIWebView, shouldStartLoadWith request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // Determine if we want the system to handle it.
        guard let url = request.URL else { return false }
        
        if url.scheme == "tappx" { //Scheme from tappx. Ignore for now
            return false
        }

        if navigationType == .LinkClicked {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.dataSource.tappxEvent(with: url)
            })

            
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
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        print("Page loaded: \(webView.request?.URL?.absoluteString)")
        self.delegate?.tappxBannerViewControllerDidFinishLoad(viewController: self)
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
        if let v = self.view as? TappxBannerView
        {
            v.injectJS("mraid.setPlacementType('inline');")
            v.setSupportsAll()
            v.stateVar = "default"
            self.setDefaultPosition()
            self.setMaxSize()
            self.setScreenSize()
            fireSizeChangeEvent()
            v.fireReadyEvent()
            v.fireViewableChangeEvent()
        }
    }
    
    func setDefaultPosition()
    {
        if let v = self.view as? TappxBannerView
        {
            if v.superview != v.window?.rootViewController?.view
            {
                let jsStr = "mraid.setDefaultPosition(\(v.superview?.frame.origin.x),\(v.superview?.frame.origin.y),\(v.superview?.frame.size.width),\(v.superview?.frame.size.height));"
                v.injectJS(jsStr)
            }
            else
            {
                let jsStr = "mraid.setDefaultPosition(\(v.frame.origin.x),\(v.frame.origin.y),\(v.frame.size.width),\(v.frame.size.height));"
                v.injectJS(jsStr)
            }
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
    
    func setMaxSize()
    {
        if let v = self.view as? TappxBannerView
        {
            if let maxSize = v.window?.rootViewController?.view.bounds.size
            {
                v.injectJS("mraid.setMaxSize(\(maxSize.width),\(maxSize.height));")
            }
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
            self.delegate?.tappxBannerViewControllerDidClose?(viewController: self)
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
    
    public func setOrientationProperties(properties : [String: Any])
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

extension TappxBannerViewController: TappxBannerViewDelegate {
    func tappxBannerviewDidPress(bannerView view: TappxBannerView) {
        self.delegate?.tappxBannerViewControllerDidPress(viewController: self)
        /*
        guard
            let value = self.banner?.headers.xclktrack.value as? String,
            let url = URL(string: value)
            else { return }
        
        DispatchQueue.global(qos: .default).async {
            self.dataSource.tappxEvent(with: url)
        }*/
    }
}
