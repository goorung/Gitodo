//
//  AuthViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/30/24.
//

import UIKit
import WebKit

import GitodoShared

import SnapKit
import SwiftyToaster

final class AuthViewController: UIViewController {
    
    private let authView = WKWebView()
    
    override func loadView() {
        super.loadView()
        self.view = authView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationCenterObserver()
        setupWebView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup NotificationCenter Observer
    
    private func setupNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginStart),
            name: .AccessTokenFetchDidStart,
            object: nil
        )
    }
    
    @objc private func handleLoginStart() {
        dismiss(animated: true)
    }
    
    private func setupWebView() {
        authView.navigationDelegate = self
        guard let url = LoginManager.shared.getLoginURL() else { return }
        authView.load(URLRequest(url: url))
    }
    
}

extension AuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
              url.scheme == "gitodo" {
            // 로그인 실패
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems,
                  let code = queryItems.first(where: { $0.name == "code" })?.value else {
                Toaster.shared.makeToast("로그인에 실패했습니다.\n다시 시도해주세요.")
                decisionHandler(.allow)
                return
            }
            // 로그인 성공
            NotificationCenter.default.post(name: .AccessTokenFetchDidStart, object: nil)
            Task {
                do {
                    try await LoginManager.shared.fetchAccessToken(with: code)
                    print("Access Token 발급 완료")
                    UserDefaultsManager.isLogin = true
                    NotificationCenter.default.post(name: .AccessTokenFetchDidEnd, object: nil)
                } catch {
                    print("Access Token 요청 실패: \(error.localizedDescription)")
                    Toaster.shared.makeToast("로그인에 실패했습니다.\n다시 시도해주세요.")
                }
                clearCookies()
            }
        }
        decisionHandler(.allow)
    }
    
    private func clearCookies() {
        let websiteDataTypes = Set([WKWebsiteDataTypeCookies])
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            print("WKWebView Cookies 삭제 완료")
        }
    }
    
}
