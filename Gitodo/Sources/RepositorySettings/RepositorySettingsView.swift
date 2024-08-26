//
//  RepositorySettingsView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

import RxCocoa
import RxSwift
import SnapKit

protocol RepositorySettingsDelegate: AnyObject {
    func presentRepositoryInfoViewController(repository: MyRepo)
}

final class RepositorySettingsView: UIView {
    
    weak var delegate: RepositorySettingsDelegate?
    private weak var viewModel: RepositorySettingsViewModel?
    private let disposeBag = DisposeBag()
    
    private let heightForRow: CGFloat = 50.0
    private var myRepositoryTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private lazy var myRepositoryPreview = {
        let collectionView = MyRepoInfoCollectionView(isEditMode: true)
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var myRepositoryLabel = {
        let label = UILabel()
        label.text = "나의 레포지토리"
        label.textColor = .darkGray
        label.font = .callout
        return label
    }()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var myRepositoryTableView = {
        let tableView = UITableView()
        tableView.rowHeight = heightForRow
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.register(cellType: MyRepoCell.self)
        return tableView
    }()
    
    private lazy var emptyView = EmptyView(
        message: "레포지토리가 없습니다 🫥\n+ 버튼을 눌러 레포지토리를 추가해보세요!"
    )
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(myRepositoryPreview)
        myRepositoryPreview.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        addSubview(myRepositoryLabel)
        myRepositoryLabel.snp.makeConstraints { make in
            make.top.equalTo(myRepositoryPreview.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(myRepositoryLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(myRepositoryTableView)
        myRepositoryTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            self.myRepositoryTableViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(heightForRow * 2)
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        myRepositoryTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let cell = myRepositoryTableView.cellForRow(at: indexPath) as? MyRepoCell,
                      let repo = cell.getRepo()
                else { return }
                generateHaptic()
                delegate?.presentRepositoryInfoViewController(repository: repo)
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: RepositorySettingsViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.myRepos
            .drive { [weak self] repos in
                guard let self = self else { return }
                myRepositoryPreview.repos = repos
            }.disposed(by: disposeBag)
        
        viewModel.output.myRepos
            .do(onNext: { [weak self] repos in
                guard let self = self else { return }
                emptyView.isHidden = !repos.isEmpty
                let height = CGFloat(repos.count) * heightForRow
                myRepositoryTableViewHeightConstraint?.update(offset: height)
                myRepositoryTableView.layoutIfNeeded() // 즉시 레이아웃 업데이트
            })
            .drive(myRepositoryTableView.rx.items(
                cellIdentifier: MyRepoCell.reuseIdentifier,
                cellType: MyRepoCell.self)
            ) { _, repo, cell in
                cell.configure(with: repo)
            }.disposed(by: disposeBag)
    }
    
}

// MARK: - MyRepoInfoCollectionView

extension RepositorySettingsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionView = collectionView as? MyRepoInfoCollectionView else { return }
        let repo = collectionView.repos[indexPath.row]
        generateHaptic()
        delegate?.presentRepositoryInfoViewController(repository: repo)
    }
    
}

// MARK: - MyRepositoryTableView

extension RepositorySettingsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let hideAction = UIContextualAction(style: .normal, title: "숨김") { [weak self] _, _, completionHandler in
            self?.viewModel?.input.hideRepo.onNext(indexPath)
            completionHandler(true)
        }
        hideAction.backgroundColor = .systemGray4
        
        return UISwipeActionsConfiguration(actions: [hideAction])
    }
    
}

extension RepositorySettingsView: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
}

extension RepositorySettingsView: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let sourceItem = coordinator.items.first,
              let sourceIndexPath = sourceItem.sourceIndexPath
        else { return }
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        viewModel?.input.updateRepoOrder.onNext((sourceIndexPath, destinationIndexPath))
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
}
