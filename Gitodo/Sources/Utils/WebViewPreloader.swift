//
//  WebViewManager.swift
//  Gitodo
//
//  Created by jiyeon on 5/30/24.
//

import UIKit
import WebKit

final class WebViewPreloader {
    
    static let shared = WebViewPreloader()
    
    private var webView = WKWebView()
    
    private init() {}
    
    func preload() {
        webView.loadHTMLString("", baseURL: nil)
    }
    
    func clear() {
        webView.stopLoading()
        webView = WKWebView()
        preload()
    }
    
    func getWebView() -> WKWebView {
        return webView
    }
    
}
