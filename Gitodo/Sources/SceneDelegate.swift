//
//  SceneDelegate.swift
//  Gitodo
//
//  Created by jiyeon on 4/24/24.
//

import UIKit

import GitodoShared

import SwiftyToaster
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        Toaster.shared.setToastType(.round)
        
        if UserDefaultsManager.isLogin {
            let mainViewModel = MainViewModel(localRepositoryService: LocalRepositoryService())
            let mainViewController = MainViewController(viewModel: mainViewModel)
            window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        } else {
            window?.rootViewController = LoginViewController()
        }
        
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url,
           url.scheme == "todoWidget" {
            if url.host == "selectRepo",
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let idItem = queryItems.first(where: { $0.name == "id" }),
               let idString = idItem.value,
               let id = Int(idString),
               let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
                
                if let mainViewController = navigationController.viewControllers.first as? MainViewController {
                    mainViewController.viewModel.input.selectRepoID.onNext(id)
                }
            }
            return
        }
        
        guard let context = URLContexts.first,
              let components = URLComponents(url: context.url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value
        else {
            Toaster.shared.makeToast("로그인에 실패했습니다.\n다시 시도해주세요.")
            return
        }
        
        NotificationCenter.default.post(name: .LoginDidStart, object: nil)
        Task {
            do {
                try await LoginManager.shared.fetchAccessToken(with: code)
                print("Access Token 발급 완료")
                UserDefaultsManager.isLogin = true
                DispatchQueue.main.async {
                    let mainViewModel = MainViewModel(localRepositoryService: LocalRepositoryService())
                    let mainViewController = MainViewController(viewModel: mainViewModel)
                    self.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
                }
            } catch {
                print("Access Token 요청 실패: \(error.localizedDescription)")
                Toaster.shared.makeToast("로그인에 실패했습니다.\n다시 시도해주세요.")
            }
            NotificationCenter.default.post(name: .LoginDidEnd, object: nil)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        reloadCurrentViewController()
    }
    
    private func reloadCurrentViewController() {
        if let navigationController = window?.rootViewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController as? Reloadable {
            visibleViewController.reloadView()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        WidgetCenter.shared.reloadAllTimelines()
    }


}

