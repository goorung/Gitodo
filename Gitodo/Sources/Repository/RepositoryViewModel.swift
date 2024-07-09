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
    }
    
    struct Output {
        var repositories: Driver<[Repository]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let viewDidLoad = PublishSubject<Void>()
    
    private let repositories = BehaviorRelay<[Repository]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    private let owner: String
    private let type: RepositoryFetchType
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    // MARK: - Initializer
    
    init(for owner: String, type: RepositoryFetchType, service: LocalRepositoryServiceProtocol) {
        self.owner = owner
        self.type = type
        self.localRepositoryService = service
        
        input = Input(
            viewDidLoad: viewDidLoad.asObserver()
        )
        
        output = Output(
            repositories: repositories.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        viewDidLoad.subscribe(onNext: { [weak self] in
            guard let self else { return }
            Task {
                do {
                    let repositoryList = try await APIManager.shared.fetchRepositories(
                        for: self.owner,
                        type: self.type
                    )
                    print(repositoryList)
                } catch let error {
                    print("[RepositoryViewModel] fetchRepositories failed : \(error.localizedDescription)")
                }
            }
        }).disposed(by: disposeBag)
    }
    
}
