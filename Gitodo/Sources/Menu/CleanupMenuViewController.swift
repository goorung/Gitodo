//
//  CleanupMenuViewController.swift
//  Gitodo
//
//  Created by 이지현 on 7/11/24.
//

import UIKit

protocol CleanupMenuDelegate: AnyObject {
    func deleteCompletedTasks()
    func toggleHideStatus()
}

class CleanupMenuViewController: UIViewController {
    weak var delegate: CleanupMenuDelegate?
    private var hideCompletedTasks: Bool
    
    // MARK: - UI Components
    
    private lazy var menuTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .background
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        return tableView
    }()
    
    // MARK: - Initializer
    
    init(hideCompletedTasks: Bool) {
        self.hideCompletedTasks = hideCompletedTasks
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let fixedWidth = 190.0
        let totalHeight = menuTableView.contentSize.height
        
        preferredContentSize = CGSize(width: fixedWidth, height: totalHeight)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        view.addSubview(menuTableView)
        menuTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaInsets)
        }
    }
    
}

extension CleanupMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier) as? MenuCell else {
            fatalError("Unable to dequeue MenuCell")
        }
        if indexPath.row == 0 {
            if hideCompletedTasks {
                cell.configure(image: UIImage(systemName: "eye"), text: "완료된 항목 보기")
            } else {
                cell.configure(image: UIImage(systemName: "eye.slash"), text: "완료된 항목 숨기기")
            }
        } else {
            cell.configure(image: UIImage(systemName: "trash"), text: "완료된 항목 모두 삭제", color: .systemRed)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            if indexPath.row == 0 {
                self?.delegate?.toggleHideStatus()
            } else {
                self?.delegate?.deleteCompletedTasks()
            }
        }
    }
}
