//
//  MenuViewController.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import UIKit

import SnapKit

protocol MenuDelegate: AnyObject {
    func pushViewController(_ menu: MainMenuType)
}

final class MenuViewController: UIViewController {
    
    weak var delegate: MenuDelegate?
    
    // MARK: - UI Components
    
    private lazy var menuTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .background
        tableView.register(cellType: MenuCell.self)
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
        
        let fixedWidth = 180.0
        let totalHeight = menuTableView.contentSize.height
        
        preferredContentSize = CGSize(width: fixedWidth, height: totalHeight)
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        view.addSubview(menuTableView)
        menuTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.pushViewController(MainMenuType.allCases[indexPath.row])
        })
    }
    
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainMenuType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self)
        cell.configure(with: MainMenuType.allCases[indexPath.row])
        return cell
    }
    
}
