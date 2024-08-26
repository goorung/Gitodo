//
//  RepositoryViewModel.swift
//  Gitodo
//
//  Created by 지연 on 7/10/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxSwift

final class RepositoryViewModel: BaseViewModel {
    
    enum RepositoryViewModelItem {
        case repository(RepositoryCellViewModel)
        case loading
    }
    
    struct Input {
        let fetchRepositories: AnyObserver<Void>
        let fetchMoreRepositories: AnyObserver<Void>
        let togglePublic: AnyObserver<IndexPath>
    }
    
    struct Output {
        var repositories: Driver<[RepositoryViewModelItem]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    private let fetchRepositories = PublishSubject<Void>()
    private let fetchMoreRepositories = PublishSubject<Void>()
    private let togglePublic = PublishSubject<IndexPath>()
    
    private let repositoryItems = BehaviorRelay<[RepositoryViewModelItem]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    // API 호출을 위한 변수들
    private let owner: Organization
    private var repositories = [Repository]()
    private let type: RepositoryFetchType
    private var currentPage = 1
    private var fetchFlag = false
    
    // MARK: - Initializer
    
    init(
        for owner: Organization,
        type: RepositoryFetchType,
        service: LocalRepositoryServiceProtocol
    ) {
        self.owner = owner
        self.type = type
        self.localRepositoryService = service
        
        input = Input(
            fetchRepositories: fetchRepositories.asObserver(),
            fetchMoreRepositories: fetchMoreRepositories.asObserver(),
            togglePublic: togglePublic.asObserver()
        )
        
        output = Output(
            repositories: repositoryItems.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        fetchRepositories.subscribe(onNext: { [weak self] in
            self?.fetchRepositories(isInitialFetch: true)
        }).disposed(by: disposeBag)
        
        fetchMoreRepositories.subscribe(onNext: { [weak self] in
            self?.fetchRepositories()
        }).disposed(by: disposeBag)
        
        togglePublic.subscribe(onNext: { [weak self] indexPath in
            self?.togglePublicRepository(at: indexPath)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepositories(isInitialFetch: Bool = false) {
        Task {
            do {
                if fetchFlag { return }
                fetchFlag = true
                
                if !isInitialFetch {
                    var currentItems = repositoryItems.value
                    currentItems.append(.loading) // 로딩 셀 추가
                    repositoryItems.accept(currentItems)
                }
                
                let repositoryList = try await APIManager.shared.fetchRepositories(
                    for: owner.login,
                    type: type,
                    page: currentPage
                )
                if !isInitialFetch && repositoryList.isEmpty {
                    var currentItems = repositoryItems.value
                    currentItems.removeLast() // 로딩 셀 제거
                    repositoryItems.accept(currentItems)
                    return
                }
                
                let publicRepos = try self.localRepositoryService.fetchPublic()
                    .filter { $0.ownerName == owner.login }
                let cellViewModels = repositoryList.map { repository in
                    let isPublic = publicRepos.contains { $0.id == repository.id }
                    return RepositoryViewModelItem.repository(RepositoryCellViewModel(
                        repository: repository.name,
                        isPublic: isPublic
                    ))
                }
                
                updateRepositories(
                    with: repositoryList,
                    cellViewModels: cellViewModels,
                    isInitialFetch: isInitialFetch
                )
                fetchFlag = false
                currentPage += 1
            } catch let error {
                print("[RepositoryViewModel] fetchRepositories failed : \(error.localizedDescription)")
            }
            if isInitialFetch {
                isLoading.accept(false)
            }
        }
    }
    
    private func updateRepositories(
        with newRepos: [Repository],
        cellViewModels: [RepositoryViewModelItem],
        isInitialFetch: Bool
    ) {
        if isInitialFetch {
            repositories = newRepos
            repositoryItems.accept(cellViewModels)
        } else {
            repositories.append(contentsOf: newRepos)
            var updatedViewModels = repositoryItems.value
            updatedViewModels.removeLast() // 로딩 셀 제거
            updatedViewModels.append(contentsOf: cellViewModels)
            repositoryItems.accept(updatedViewModels)
        }
    }
    
    private func togglePublicRepository(at indexPath: IndexPath) {
        var items = repositoryItems.value
        if case var .repository(cellViewModel) = items[indexPath.row] {
            cellViewModel.isPublic.toggle()
            items[indexPath.row] = .repository(cellViewModel)
            repositoryItems.accept(items)
            
            do {
                try localRepositoryService.updateRepository(
                    repository: repositories[indexPath.row],
                    isPublic: cellViewModel.isPublic
                )
            } catch let error {
                print("[RepositoryViewModel] updateRepository failed : \(error.localizedDescription)")
            }
        }
    }
    
    func getOwner() -> Organization {
        return owner
    }
    
}
