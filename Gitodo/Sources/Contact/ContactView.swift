//
//  ContactView.swift
//  GitodoShared
//
//  Created by jiyeon on 5/27/24.
//

import UIKit
import WebKit

import GitodoShared

import SnapKit

final class ContactView: UIView {

    private var progressObserver: NSKeyValueObservation?
    
    // MARK: - UI Components
    
    private lazy var webView = WebViewPreloader.shared.getWebView()
    
    private lazy var progressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.tintColor = UIColor(hex: PaletteColor.purple1.hex)
        view.sizeToFit()
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupWebView()
        loadWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        progressObserver?.invalidate()
        WebViewPreloader.shared.clear()
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            self?.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    private func loadWebView() {
        guard let url = URL(string: "https://github.com/goorung/Gitodo/wiki/%EC%82%AC%EC%9A%A9%EC%9E%90-%EB%A7%A4%EB%89%B4%EC%96%BC-%7C-FAQ") else { return }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}

extension ContactView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 로딩 시작 시 프로그레스 바를 보여주고 진행률 초기화
        progressView.isHidden = false
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(1.0, animated: true)
        // 약간의 딜레이 후 프로그레스 바를 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // "새 창으로 열기" 링크 WebView 내에서 열기
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
    }
    
}
