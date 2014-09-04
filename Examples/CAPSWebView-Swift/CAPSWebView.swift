//
//  CAPSWebView.swift
//  CAPSWebView-Swift
//
//  Created by Niklas Fahl on 9/2/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit
import WebKit

class CAPSWebView: UIViewController, WKNavigationDelegate, UIScrollViewDelegate
{
    var webView: WKWebView?
    var containerView: UIView?
    var progressBar: UIProgressView?
    var loadingProgressTimer: NSTimer?
    var currentProgress: Float?
    
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    
    var currentScrollOffset: CGPoint?
    
    var toolbar: UIToolbar?
    
    var urlString: NSString?
    
    var toolbarVisibleHeight: CGFloat?
    
    var primaryColor: UIColor?
    var secondaryColor: UIColor?
    
    override init()
    {
        urlString = NSString()
        
        super.init()
        
        urlString = "http://www.google.com"
    }
    
    init(url: NSString)
    {
        urlString = NSString()
        
        super.init()
        
        urlString = validateUrl(url)
    }
    
    init(url: NSString, primary: UIColor?, secondary: UIColor)
    {
        urlString = NSString()
        
        super.init()
        
        urlString = validateUrl(url)
        
        primaryColor = primary
        secondaryColor = secondary
    }
    
    func validateUrl(url: NSString) -> NSString
    {
        let httpSubstring = url as NSString
        httpSubstring.substringWithRange(NSRange(location: 0,length: 3))
        
        // Do more validation for correct url input
        if (httpSubstring != "http") {
            return "https://\(url)"
        } else {
            return url
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func loadView()
    {
        super.loadView()
        
        self.webView = WKWebView()

        self.webView?.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        self.webView?.sizeToFit()
        self.containerView = self.webView!
        self.view.addSubview(self.containerView!)
        
        self.webView?.navigationDelegate = self
        self.webView?.scrollView.delegate = self
        self.webView?.sizeToFit()
        self.webView?.clipsToBounds = true
        self.webView?.scrollView.clipsToBounds = true
        
        currentScrollOffset = self.webView?.scrollView.contentOffset
        
        progressBar = UIProgressView(frame: CGRectMake(0, 42, 320, 2))
        self.navigationController?.navigationBar.addSubview(progressBar!)
        
        var reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadPage")
        var fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)
        fixedSpace.width = 40.0
        backButton = UIBarButtonItem(image: UIImage(named: "Previous"), style: UIBarButtonItemStyle.Plain, target: self, action: "backPage")
        backButton!.enabled = false
        forwardButton = UIBarButtonItem(image: UIImage(named: "Next"), style: UIBarButtonItemStyle.Plain, target: self, action: "forwardPage")
        forwardButton!.enabled = false
        
        var flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        var actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "openActionSheet")
        
        toolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.height - 44.0, 320, 44))
        toolbar!.items = [backButton!, fixedSpace, forwardButton!, flexibleSpace, actionButton, fixedSpace, reloadButton]
        self.view.addSubview(toolbar!)
        
        // Set autoresizing masks
        self.webView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.containerView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.toolbar?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        progressBar?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        
        // Set colors
        if (secondaryColor != nil) {
            setUIColors(primaryColor, secondary: secondaryColor!)
        }
        
        self.title = urlString
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // add observer for estimated progress
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
        var url = NSURL(string:urlString!)
        var req = NSURLRequest(URL:url)
        self.webView!.loadRequest(req)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>)
    {
        var webView : WKWebView = object as WKWebView
        
        var previousProgress : Double = 0.0
        if currentProgress != nil {
            previousProgress = Double(currentProgress!)
        }
        
        currentProgress = Float(object.estimatedProgress)
        
        println(currentProgress)
        
        if object.estimatedProgress == 1.0
        {
            var interval : Double = 1.3 - previousProgress
            
            NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector:"resetProgress", userInfo: nil, repeats: false)
        }
    }
    
    func startLoading()
    {
        progressBar?.progress = 0.0
        
        loadingProgressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector:"updateProgress", userInfo: nil, repeats: true)
    }
    
    func updateProgress()
    {
        progressBar?.setProgress(currentProgress!, animated: true)
    }
    
    func resetProgress()
    {
        loadingProgressTimer?.invalidate()
        
        progressBar?.progress = 0.0
        progressBar?.alpha = 0.0
        currentProgress = 0.0
    }
    
    func webView(webView: WKWebView!, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        progressBar?.alpha = 1.0
        
        self.title = "\(self.webView!.URL)"
        
        startLoading()
    }
    
    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!)
    {
        self.title = self.webView?.title
        
        // set back/forward button enabled based on cangoback/cangoforward
        if self.webView!.canGoBack {
            self.backButton?.enabled = true
        } else {
            self.backButton?.enabled = false
        }
        
        if self.webView!.canGoForward {
            self.forwardButton?.enabled = true
        } else {
            self.forwardButton?.enabled = false
        }
        
        println("content height \(self.webView?.scrollView.contentSize.height)")
    }
    
    func reloadPage()
    {
        var url = self.webView?.URL
        var req = NSURLRequest(URL:url!)
        self.webView!.loadRequest(req)
    }
    
    func backPage()
    {
        self.webView?.goBack()
    }
    
    func forwardPage()
    {
        self.webView?.goForward()
    }
    
    func openActionSheet()
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: UIAlertActionStyle.Default) { action in
            self.openUrlInSafari(self.webView!.URL)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func openUrlInSafari(url: NSURL)
    {
        UIApplication.sharedApplication().openURL(url)
    }
    
    func setUIColors(primary: UIColor?, secondary: UIColor)
    {
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(object:secondary, forKey:NSForegroundColorAttributeName)
        
        if (primary != nil) {
            self.navigationController!.navigationBar.barTintColor = primary
            self.toolbar?.barTintColor = primary
        }
        
        self.navigationController!.navigationBar.tintColor = secondary
        self.toolbar?.tintColor = secondary
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var offset : CGPoint = scrollView.contentOffset;
        var bounds : CGRect = scrollView.bounds;
        var size : CGSize = scrollView.contentSize;
        var inset : UIEdgeInsets = scrollView.contentInset;
        var y : CGFloat = offset.y + bounds.size.height - inset.bottom;
        var h : CGFloat = size.height;
        
        var lastOffset: CGPoint = currentScrollOffset!
        currentScrollOffset = scrollView.contentOffset
        
        var deltaY = currentScrollOffset!.y - lastOffset.y
        
        toolbarVisibleHeight = self.view.frame.height - self.toolbar!.frame.origin.y;
        println("toolbar visible \(toolbarVisibleHeight)px")
        
        var offsetCutoff : CGFloat = -64.0
        
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight) {
            offsetCutoff = -32.0
        }
        
        if (currentScrollOffset!.y > offsetCutoff) {
            if (h > 0) {
                if (y >= h) {
                    // ***Code to fade in toolbar when scrolling past bounds on bottom. Problems with webview resizing prevent me from using this 'feature' at this time***
                    
//                    if (self.toolbar!.frame.origin.y > self.view.bounds.size.height - 44.0) {
//                        if (self.toolbar!.frame.origin.y - deltaY > self.view.frame.height - 44.0) {
//                            self.toolbar?.frame = CGRectMake(0, self.toolbar!.frame.origin.y - deltaY, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
//                        } else {
//                            self.toolbar?.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
//                        }
//                    }
//                    
//                    println("scrolling past bottom bounds toolbar opening")
                } else {
                    if (y >= 0 && y < h) {
                        if (deltaY >= 0) {
                            if (self.toolbar!.frame.origin.y >= self.view.bounds.height - 44.0 && self.toolbar!.frame.origin.y <= self.view.bounds.height) {
                                println("scrolling down toolbar closing")
                                if (self.toolbar!.frame.origin.y + deltaY < self.view.frame.height) {
                                    self.toolbar?.frame = CGRectMake(0, self.toolbar!.frame.origin.y + deltaY, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                                } else {
                                    self.toolbar?.frame = CGRectMake(0, self.view.frame.height, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                                }
                            }
                        } else if (deltaY < 0) {
                            if (self.toolbar!.frame.origin.y > self.view.bounds.size.height - 44.0) {
                                if (self.toolbar!.frame.origin.y + deltaY > self.view.frame.height - 44.0) {
                                    self.toolbar?.frame = CGRectMake(0, self.toolbar!.frame.origin.y + deltaY, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                                } else {
                                    self.toolbar?.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                                }
                            }
                            println("scrolling up toolbar opening")
                        }
                    }
                }
            }
        } else {
            self.toolbar?.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        println("ended scroll")
        
        var interval : NSTimeInterval = 0.2
        
        if (toolbarVisibleHeight > 22.0) { // fully open toolbar
            UIView.animateWithDuration(0.2, animations: {
                self.toolbar!.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
            })
        } else { // fully close toolbar
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.toolbar!.frame = CGRectMake(0, self.view.frame.height, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
            })
        }
    }
}
