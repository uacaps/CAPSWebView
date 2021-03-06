CAPSWebView (PRE-RELEASE)
=========================

A web page viewer utilizing the new WKWebView for iOS 8 written in Swift

## Installation

**Cocoa Pods**

Coming in the future.

**Manual Installation**

All the classes and images required for CAPSWebView are located in the CAPSWebView folder in the root of this repository. They are listed below:

* <code>CAPSWebView.swift<code>
* <code>Next.png<code>
* <code>Next@2x.png<code>
* <code>Previous.png<code>
* <code>Previous@2x.png<code>

## How to use CAPSWebView

In order to use CAPSWebView you should either use the existing navigation controller of your app if your app utilizes one or create a new navigation controller. After that you should push CAPSWebView to the navigation controller. An example of pushing CAPSWebView can be found below.

```objective-c
// Push CAPSWebView initializing just secondary color and url
self.testNavigationController!.pushViewController(CAPSWebView(url: "google.com", primary: nil, secondary: UIColor.grayColor()), animated: false)
```


## Future Work

* Objective-C version
* Support for iOS 7 and below by use of UIWebView
* etc.

## License ##

Copyright (c) 2014 The Board of Trustees of The University of Alabama
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of the University nor the names of the contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
