//
//  MainViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

import RxCocoa
import RxSwift

final class MainViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let viewWillAppear: AnyObserver<Void>
        let selectRepoIndex: AnyObserver<Int>
    }
    
    struct Output {
        var selectedRepo: Driver<MyRepo?>
        var repos: Driver<[MyRepo]>
    }
    
    private var selectedRepo = BehaviorRelay<MyRepo?>(value: nil)
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let selectRepoIndexSubject = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService
        
        input = Input(
            viewWillAppear: viewWillAppearSubject.asObserver(),
            selectRepoIndex: selectRepoIndexSubject.asObserver()
        )
        output = Output(
            selectedRepo: selectedRepo.asDriver(onErrorJustReturn: nil),
            repos: repos.asDriver(onErrorJustReturn: [])
        )
        
        viewWillAppearSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        selectRepoIndexSubject.subscribe(onNext: { [weak self] index in
            let repo = self?.repos.value[index]
            self?.selectedRepo.accept(repo)
        }).disposed(by: disposeBag)
        
    }
    
    private func fetchRepos() {
        let fetchedRepos = TempRepository.getRepos().filter { $0.isPublic }
//        let fetchedRepos = localRepositoryService.fetchAllRepositories().filter { $0.isPublic }
        repos.accept(fetchedRepos)
        if selectedRepo.value == nil && fetchedRepos.count > 0 {
            selectedRepo.accept(fetchedRepos[0])
        } else {
            selectedRepo.accept(selectedRepo.value)
        }
    }
    
}
