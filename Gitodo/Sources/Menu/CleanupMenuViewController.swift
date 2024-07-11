//
//  CleanupMenuViewController.swift
//  Gitodo
//
//  Created by 이지현 on 7/11/24.
//

import UIKit

class CleanupMenuViewController: UIViewController {
//    weak var delegate: MenuDelegate?
    
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
            cell.configure(image: UIImage(systemName: "eye.slash"), text: "완료된 항목 숨김")
        } else {
            cell.configure(image: UIImage(systemName: "trash"), text: "완료된 항목 모두 삭제", color: .systemRed)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("숨김 버튼 클릭")
        } else {
            print("모두 삭제 버튼 클릭")
        }
        dismiss(animated: true)
    }
}
