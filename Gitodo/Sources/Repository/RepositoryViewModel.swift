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
    
    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let togglePublic: AnyObserver<IndexPath>
    }
    
    struct Output {
        var repositories: Driver<[RepositoryCellViewModel]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let viewDidLoad = PublishSubject<Void>()
    private let togglePublic = PublishSubject<IndexPath>()
    
    private let repositoryCellViewModels = BehaviorRelay<[RepositoryCellViewModel]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    private let owner: Organization
    private var repositories: [Repository]?
    private let type: RepositoryFetchType
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
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
            viewDidLoad: viewDidLoad.asObserver(),
            togglePublic: togglePublic.asObserver()
        )
        
        output = Output(
            repositories: repositoryCellViewModels.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        viewDidLoad.subscribe(onNext: { [weak self] in
            self?.fetchRepositoriesWithLocal()
        }).disposed(by: disposeBag)
        
        togglePublic.subscribe(onNext: { [weak self] indexPath in
            self?.togglePublicRepository(at: indexPath)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepositoriesWithLocal() {
        isLoading.accept(true)
        Task {
            do {
                // fetch
                let repositoryList = try await APIManager.shared.fetchRepositories(
                    for: owner.login,
                    type: type
                )
                self.repositories = repositoryList
                // local
                let ownerPublicRepository = try self.localRepositoryService.fetchPublic()
                    .filter { $0.ownerName == owner.login }
                // 뷰 모델 생성, 로컬 데이터를 기반으로 isPublic 플래그 설정
                let cellViewModel = repositoryList.map { repository in
                    let isPublic = ownerPublicRepository.contains { $0.id == repository.id }
                    return RepositoryCellViewModel(repository: repository.name, isPublic: isPublic)
                }
                repositoryCellViewModels.accept(cellViewModel)
            } catch let error {
                print("[RepositoryViewModel] fetchRepositories failed : \(error.localizedDescription)")
            }
            isLoading.accept(false)
        }
    }
    
    private func togglePublicRepository(at indexPath: IndexPath) {
        var cellViewModels = repositoryCellViewModels.value
        cellViewModels[indexPath.row].isPublic.toggle()
        repositoryCellViewModels.accept(cellViewModels)
    }
    
    func getOwner() -> Organization {
        return owner
    }
    
}
