//
//  RepositorySettingsView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import SnapKit

protocol RepositorySettingsDelegate: AnyObject {
    func presentAlertViewController(completion: @escaping (() -> Void))
    func presentRepositoryInfoViewController(repository: Repository)
}

class RepositorySettingsView: UIView {
    
    // temp !
    
    var tempRepo = [
        Repository(id: 1, nickname: "algorithm", symbol: "🪼", hexColor: PaletteColor.blue.hex),
        Repository(id: 2, nickname: "iOS", symbol: "🍄", hexColor: PaletteColor.yellow.hex),
        Repository(id: 1, nickname: "algorithm", symbol: "🪼", hexColor: PaletteColor.blue.hex),
        Repository(id: 2, nickname: "iOS", symbol: "🍄", hexColor: PaletteColor.yellow.hex),
        Repository(id: 1, nickname: "algorithm", symbol: "🪼", hexColor: PaletteColor.blue.hex),
        Repository(id: 2, nickname: "iOS", symbol: "🍄", hexColor: PaletteColor.yellow.hex),
        Repository(id: 1, nickname: "algorithm", symbol: "🪼", hexColor: PaletteColor.blue.hex),
        Repository(id: 2, nickname: "iOS", symbol: "🍄", hexColor: PaletteColor.yellow.hex),
        Repository(id: 1, nickname: "algorithm", symbol: "🪼", hexColor: PaletteColor.blue.hex),
        Repository(id: 2, nickname: "iOS", symbol: "🍄", hexColor: PaletteColor.yellow.hex),
    ]
    
    private let repos = [
        "레포지토리 1",
        "레포지토리 2",
        "레포지토리 3",
        "레포지토리 4",
        "레포지토리 5",
        "레포지토리 6",
        "레포지토리 7",
        "레포지토리 8",
        "레포지토리 9",
        "레포지토리 10"
    ]
    
    private var deletedRepos = [
        "삭제된 레포지토리 1",
        "삭제된 레포지토리 2",
        "삭제된 레포지토리 3",
        "삭제된 레포지토리 4",
        "삭제된 레포지토리 5"
    ]
    
    weak var delegate: RepositorySettingsDelegate?
    
    private let insetFromSuperView: CGFloat = 20.0
    private let insetFromContentSuperViewTop: CGFloat = 10.0
    private let offsetFromPreviewView: CGFloat = 10.0
    private let offsetFromOtherView: CGFloat = 25.0
    private let offsetFromFriendView: CGFloat = 10.0
    private let heightForRow: CGFloat = 50.0
    
    // MARK: - UI Components
    
    private lazy var previewView = {
        let collectionView = RepoCollectionView(repos: tempRepo)
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var repoLabel = createLabel(withText: "할 일을 관리하고 싶은 레포지토리를 선택하세요")
    
    private lazy var repoTableView = {
        let tableView = createTableView()
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var deletedRepoLabel = {
        let label = createLabel(withText: "원격 저장소에서 삭제된 레포지토리")
        label.isHidden = deletedRepos.count == 0
        return label
    }()
    
    private lazy var deletedRepoTableView = {
        let tableView = createTableView()
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        tableView.setEditing(true, animated: false)
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
            make.top.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(80)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(offsetFromPreviewView)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(repoLabel)
        repoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(insetFromContentSuperViewTop)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(repoTableView)
        repoTableView.snp.makeConstraints { make in
            make.top.equalTo(repoLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(heightForRow * CGFloat(repos.count))
        }
        
        contentView.addSubview(deletedRepoLabel)
        deletedRepoLabel.snp.makeConstraints { make in
            make.top.equalTo(repoTableView.snp.bottom).offset(offsetFromOtherView)
            make.leading.equalToSuperview().inset(insetFromSuperView)
        }
        
        contentView.addSubview(deletedRepoTableView)
        deletedRepoTableView.snp.makeConstraints { make in
            make.top.equalTo(deletedRepoLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(heightForRow * CGFloat(deletedRepos.count))
            make.bottom.equalToSuperview().inset(insetFromSuperView)
        }
    }
    
    func updateRepository(_ repository: Repository) {
        guard let index = tempRepo.firstIndex(where: { $0.id == repository.id}) else { return }
        tempRepo[index].nickname = repository.nickname
        tempRepo[index].symbol = repository.symbol
        tempRepo[index].hexColor = repository.hexColor
        previewView.repos = tempRepo
    }
    
}

extension RepositorySettingsView {
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 13)
        return label
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .systemBackground
        tableView.isScrollEnabled = false
        return tableView
    }
    
}

extension RepositorySettingsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == repoTableView, let cell = tableView.cellForRow(at: indexPath) as? RepositoryCell else { return }
        if cell.selectCell() { // 추가
            print("\(repos[indexPath.row]) 추가")
        } else { // 삭제
            print("\(repos[indexPath.row]) 삭제")
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == deletedRepoTableView {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.presentAlertViewController { [weak self] in
                guard let self = self else { return }
                deletedRepos.remove(at: indexPath.row)
                tableView.reloadData()
                remakeDeletedRepoTableViewConstraints()
            }
        }
    }
    
    private func remakeDeletedRepoTableViewConstraints() {
        deletedRepoTableView.snp.remakeConstraints { make in
            make.top.equalTo(deletedRepoLabel.snp.bottom).offset(offsetFromFriendView)
            make.leading.trailing.equalToSuperview().inset(insetFromSuperView)
            make.height.equalTo(heightForRow * CGFloat(deletedRepos.count))
            make.bottom.equalToSuperview().inset(insetFromSuperView)
        }
    }
    
}

extension RepositorySettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == repoTableView {
            return repos.count
        } else {
            return deletedRepos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier) as? RepositoryCell else {
            fatalError("Unable to dequeue RepositoryCell")
        }
        if tableView == repoTableView {
            cell.configure(withName: repos[indexPath.row])
        } else {
            cell.configure(withName: deletedRepos[indexPath.row])
        }
        return cell
    }
    
}

extension RepositorySettingsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.presentRepositoryInfoViewController(repository: tempRepo[indexPath.row])
    }
}
