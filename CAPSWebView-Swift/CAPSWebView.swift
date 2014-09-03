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
    
    override func loadView()
    {
        super.loadView()
        
        self.webView = WKWebView()

        self.webView?.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        self.webView?.sizeToFit()
        self.containerView = self.webView!

        self.view.addSubview(self.containerView!)
        
        //self.view = self.webView!
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
        var actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil)
        
        toolbar = UIToolbar(frame: CGRectMake(0, self.view.bounds.height - 44.0, 320, 44))
        toolbar!.items = [backButton!, fixedSpace, forwardButton!, flexibleSpace, actionButton, fixedSpace, reloadButton]
        self.view.addSubview(toolbar!)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // add observer for estimated progress
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
        var url = NSURL(string:"http://google.com")
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
    
    @IBAction func didSelectBackButton(sender: AnyObject)
    {
        self.webView?.goBack()
    }
    
    @IBAction func didSelectForwardButton(sender: AnyObject)
    {
        self.webView?.goForward()
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
        
        if (currentScrollOffset!.y > -64.0) {
            if (h > 0) {
                if (y > h) {
                    if (self.toolbar!.frame.origin.y > self.view.bounds.size.height - 44.0) {
                        if (self.toolbar!.frame.origin.y - deltaY > self.view.frame.height - 44.0) {
                            self.toolbar?.frame = CGRectMake(0, self.toolbar!.frame.origin.y - deltaY, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                        } else {
                            self.toolbar?.frame = CGRectMake(0, self.view.bounds.size.height - 44.0, self.toolbar!.frame.size.width, self.toolbar!.frame.size.height)
                        }
                    }
                    println("scrolling past bounds toolbar opening")
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
}
