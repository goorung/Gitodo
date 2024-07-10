//
//  LoadableView.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import UIKit

import SnapKit

class LoadableView: UIView {
    
    // MARK: - UI Components
    
    private(set) lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func showLoading() {
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.loadingView.isHidden = true
        }
    }
    
}
