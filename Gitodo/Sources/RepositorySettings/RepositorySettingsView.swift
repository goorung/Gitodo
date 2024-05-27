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
    func presentAlertViewController(completion: @escaping (() -> Void))
    func presentRepositoryInfoViewController(repository: MyRepo)
}

final class RepositorySettingsView: UIView {
    
    private var viewModel: RepositorySettingsViewModel?
    private let disposeBag = DisposeBag()
    weak var delegate: RepositorySettingsDelegate?
    
    private let heightForRow: CGFloat = 50.0
    private var repoTableViewHeightConstraint: Constraint?
    private var deletedRepoTableViewHeightConstraint: Constraint?
    
    // MARK: - UI Components
    
    private lazy var previewView = {
        let collectionView = RepoCollectionView(isEditMode: true)
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
    
    private lazy var emptyView = {
        let view = UIView()
        view.backgroundColor = .background
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var emptyLabel = {
        let label = UILabel()
        let text = """
        생성된 레포지토리가 없습니다 🫥
        Github에서 레포지토리를 추가해보세요!
        """
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.textAlignment = .center
        label.font = .bodySB
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var deletedRepoLabel = {
        let label = createLabel(withText: "원격 저장소에서 삭제된 레포지토리")
        return label
    }()
    
    private lazy var deletedRepoTableView = {
        let tableView = createTableView()
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var loadingView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private lazy var loadingIndicator = UIActivityIndicatorView()
    
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
        addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(previewView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(repoLabel)
        repoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(repoTableView)
        repoTableView.snp.makeConstraints { make in
            make.top.equalTo(repoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            self.repoTableViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(repoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(heightForRow * 2)
        }
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(deletedRepoLabel)
        deletedRepoLabel.snp.makeConstraints { make in
            make.top.equalTo(repoTableView.snp.bottom).offset(25)
            make.leading.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(deletedRepoTableView)
        deletedRepoTableView.snp.makeConstraints { make in
            make.top.equalTo(deletedRepoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            self.deletedRepoTableViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview().inset(20)
        }
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        repoTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let cell = repoTableView.cellForRow(at: indexPath) as? RepositoryCell,
                      let repo = cell.getRepo()
                else { return }
                generateHaptic()
                cell.select()
                viewModel?.input.togglePublic.onNext(repo)
            }).disposed(by: disposeBag)
        
        deletedRepoTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let cell = deletedRepoTableView.cellForRow(at: indexPath) as? RepositoryCell,
                      let repo = cell.getRepo()
                else { return }
                generateHaptic()
                cell.select()
                viewModel?.input.togglePublic.onNext(repo)
            }).disposed(by: disposeBag)
        
        deletedRepoTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let cell = deletedRepoTableView.cellForRow(at: indexPath) as? RepositoryCell,
                      let repo = cell.getRepo()
                else { return }
                delegate?.presentAlertViewController(completion: { [weak self] in
                    self?.viewModel?.input.removeRepo.onNext(repo)
                })
            }).disposed(by: disposeBag)
    }
    
    func bind(with viewModel: RepositorySettingsViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.publicRepos
            .drive { [weak self] repos in
                guard let self = self else { return }
                previewView.repos = repos
            }.disposed(by: disposeBag)
        
        viewModel.output.repos
            .map { $0.filter { !$0.isDeleted } }
            .do(onNext: { [weak self] repos in
                guard let self = self else { return }
                emptyView.isHidden = !repos.isEmpty
                let height = CGFloat(repos.count) * heightForRow
                repoTableViewHeightConstraint?.update(offset: height)
                repoTableView.layoutIfNeeded() // 즉시 레이아웃 업데이트
            })
            .drive(repoTableView.rx.items(
                cellIdentifier: RepositoryCell.reuseIdentifier,
                cellType: RepositoryCell.self)
            ) { _, repo, cell in
                cell.configure(with: repo)
            }.disposed(by: disposeBag)
        
        viewModel.output.repos
            .map { $0.filter { $0.isDeleted } }
            .do(onNext: { [weak self] repos in
                guard let self = self else { return }
                deletedRepoLabel.isHidden = repos.isEmpty
                let height = CGFloat(repos.count) * heightForRow
                deletedRepoTableViewHeightConstraint?.update(offset: height)
                deletedRepoTableView.layoutIfNeeded() // 즉시 레이아웃 업데이트
            })
            .drive(deletedRepoTableView.rx.items(
                cellIdentifier: RepositoryCell.reuseIdentifier,
                cellType: RepositoryCell.self)
            ) { _, repo, cell in
                cell.configure(with: repo)
            }.disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.isHidden = false
                    self?.loadingIndicator.startAnimating()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.loadingIndicator.stopAnimating()
                        self?.loadingView.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)
    }
    
}

extension RepositorySettingsView {
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .darkGray
        label.font = .callout
        return label
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.rowHeight = heightForRow
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .background
        tableView.isScrollEnabled = false
        return tableView
    }
    
}

extension RepositorySettingsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionView = collectionView as? RepoCollectionView else { return }
        let repo = collectionView.repos[indexPath.row]
        generateHaptic()
        delegate?.presentRepositoryInfoViewController(repository: repo)
    }
    
}
