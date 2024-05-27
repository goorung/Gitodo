//
//  ContactViewController.swift
//  GitodoShared
//
//  Created by jiyeon on 5/27/24.
//

import UIKit

final class ContactViewController: BaseViewController<ContactView>, BaseViewControllerProtocol, UIGestureRecognizerDelegate {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    // MARK: - Setup Navigation Bar
    
    func setupNavigationBar() {
        setTitle("문의하기")
        setLeftBackButton()
        setInteractivePopGestureRecognizer()
    }
    
    private func setInteractivePopGestureRecognizer() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
