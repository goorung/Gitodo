//
//  RepositorySettingsView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

class RepositorySettingsView: UIView {
    
    // temp !
    private var selectedItems = [String]()
    
    private let items = [
        "레포지토리 1",
        "레포지토리 2",
        "레포지토리 3",
        "레포지토리 4",
        "레포지토리 5"
    ]
    
    private let insetFromSuperView: CGFloat = 20.0
    private let offsetFromOtherView: CGFloat = 25.0
    private let offsetFromFriendView: CGFloat = 10.0
    private let heightForRow: CGFloat = 50.0
    
    // MARK: - UI Components
    
    private lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var selectedRepositoryView: UITableView = {
        let tableView = createTableView()
        tableView.register(SelectedRepositoryCell.self, forCellReuseIdentifier: SelectedRepositoryCell.reuseIdentifier)
        tableView.setEditing(true, animated: true)
        return tableView
    }()
    
    private lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.text = "할 일을 관리하고 싶은 레포지토리를 선택하세요"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var repositoryListView: UITableView = {
        let tableView = createTableView()
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        addSubview(selectedRepositoryView)
        selectedRepositoryView.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(offsetFromOtherView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(heightForRow * CGFloat(selectedItems.count))
        }
        
        addSubview(guideLabel)
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedRepositoryView.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        addSubview(repositoryListView)
        repositoryListView.snp.makeConstraints { make in
            make.top.equalTo(guideLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(heightForRow * CGFloat(items.count))
        }
    }
    
}

extension RepositorySettingsView {
    
    private func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }
    
}

extension RepositorySettingsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == repositoryListView {
            guard let cell = tableView.cellForRow(at: indexPath) as? RepositoryCell else { return }
            if cell.selectCell() { // 추가
                selectedItems.append(items[indexPath.row])
            } else { // 삭제
                for (index, item) in selectedItems.enumerated() {
                    if item == items[indexPath.row] {
                        selectedItems.remove(at: index)
                        break
                    }
                }
            }
            selectedRepositoryView.reloadData()
            selectedRepositoryView.snp.remakeConstraints { make in
                make.top.equalTo(previewView.snp.bottom).offset(offsetFromOtherView)
                make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
                make.height.equalTo(heightForRow * CGFloat(selectedItems.count))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView == selectedRepositoryView
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = selectedItems[sourceIndexPath.row]
        selectedItems.remove(at: sourceIndexPath.row)
        selectedItems.insert(movedObject, at: destinationIndexPath.row)
        print(selectedItems)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension RepositorySettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == repositoryListView {
            return items.count
        } else {
            return selectedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == repositoryListView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier) as? RepositoryCell else {
                fatalError("Unable to dequeue RepositoryCell")
            }
            cell.configure(withName: items[indexPath.row])
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectedRepositoryCell.reuseIdentifier) as? SelectedRepositoryCell else {
                fatalError("Unable to dequeue SelectedRepositoryCell")
            }
            cell.configure(withName: selectedItems[indexPath.row])
            return cell
        }
    }
    
}
