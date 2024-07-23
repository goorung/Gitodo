//
//  DeletionOptionView.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import SnapKit

class DeletionOptionView: UIView {
    
    let options = ["삭제 안 함", "바로 삭제", "매일 특정 시간 삭제", "시간 선택", "특정 시간 이후 삭제"]
    
    lazy var optionTableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseIdentifier)
        tableView.register(TimeOptionCell.self, forCellReuseIdentifier: TimeOptionCell.reuseIdentifier)
        tableView.dataSource = self
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
        }
    }
    
    
}

extension DeletionOptionView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            guard let cell = optionTableView.dequeueReusableCell(withIdentifier: TimeOptionCell.reuseIdentifier, for: indexPath) as? TimeOptionCell else { fatalError() }
            return cell
        }
        
        guard let cell = optionTableView.dequeueReusableCell(withIdentifier: OptionCell.reuseIdentifier, for: indexPath) as? OptionCell else { fatalError() }
        cell.configure(title: options[indexPath.row])
        return cell
    }
    
}


