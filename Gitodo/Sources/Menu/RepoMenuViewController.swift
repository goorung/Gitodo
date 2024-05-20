//
//  RepoMenuViewController.swift
//  Gitodo
//
//  Created by 이지현 on 5/20/24.
//

import UIKit

import SnapKit

protocol RepoMenuDelegate: AnyObject {
    func pushViewController(_ repoMenu: RepoMenuType, _ repo: MyRepo)
}

class RepoMenuViewController: UIViewController {
    
    weak var delegate: RepoMenuDelegate?
    let repo: MyRepo
    
    let buttonWidth = 60
    let buttonHeight = 35
    let buttonFontSize = 13
    let separatorWidth = 1
    
    // MARK: - UI Components
    
    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = CGFloat(separatorWidth)
        stackView.backgroundColor = .systemGray6
        return stackView
    }()
    
    private lazy var editButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle(RepoMenuType.allCases[0].title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: CGFloat(buttonFontSize))
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var hideButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle(RepoMenuType.allCases[1].title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: CGFloat(buttonFontSize))
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    init(repo: MyRepo) {
        self.repo = repo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let fixedWidth = buttonWidth * 2 + separatorWidth
        let fixedHeight = buttonHeight
        
        preferredContentSize = CGSize(width: fixedWidth, height: fixedHeight)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        
        editButton.snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        
        hideButton.snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(hideButton)
    }
    
    @objc private func editButtonTapped() {
        dismiss(animated: true)
        delegate?.pushViewController(.edit, repo)
    }
    @objc private func hideButtonTapped() {
        dismiss(animated: true)
        delegate?.pushViewController(.hide, repo)
    }
    
}
