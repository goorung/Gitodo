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

final class AuthViewController: BaseViewController<AuthView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.delegate = self
    }
    
}

extension AuthViewController: AuthViewDelegate {
    
    func handleLogin(url: URL) {
        // 로그인 실패
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value else {
            Toaster.shared.makeToast("로그인에 실패했습니다.\n다시 시도해주세요.")
            dismiss(animated: true)
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
        dismiss(animated: true)
    }
    
    private func clearCookies() {
        let websiteDataTypes = Set([WKWebsiteDataTypeCookies])
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            print("WKWebView Cookies 삭제 완료")
        }
    }
    
}
