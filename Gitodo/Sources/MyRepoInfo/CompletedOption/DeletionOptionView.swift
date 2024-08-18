//
//  DeletionOptionView.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import GitodoShared

import SnapKit

class DeletionOptionView: UIView {
    
    weak var viewModel: MyRepoInfoViewModel?
    
    lazy var optionTableView = {
        let tableView = SelfSizingTableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        tableView.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        tableView.register(DeletionOptionCell.self, forCellReuseIdentifier: DeletionOptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(optionTableView)
        optionTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }
    
    
}

extension DeletionOptionView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DeletionOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = optionTableView.dequeueReusableCell(withIdentifier: DeletionOptionCell.reuseIdentifier, for: indexPath) as? DeletionOptionCell,
              let viewModel = viewModel else { fatalError() }
        cell.configure(option: DeletionOption.allCases[indexPath.row], isSelected: viewModel.deletionOption.id == indexPath.row)
        return cell
    }
    
}

extension DeletionOptionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.deletionOption = DeletionOption.allCases[indexPath.row]
        tableView.reloadData()
    }
}


