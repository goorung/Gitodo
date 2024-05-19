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
        let resetAllRepository: AnyObserver<Void>
    }
    
    struct Output {
        var selectedRepo: Driver<MyRepo?>
        var repos: Driver<[MyRepo]>
    }
    
    private var selectedRepo = BehaviorRelay<MyRepo?>(value: nil)
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let selectRepoIndexSubject = PublishSubject<Int>()
    private let resetAllRepositorySubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService
        
        input = Input(
            viewWillAppear: viewWillAppearSubject.asObserver(),
            selectRepoIndex: selectRepoIndexSubject.asObserver(),
            resetAllRepository: resetAllRepositorySubject.asObserver()
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
        
        resetAllRepositorySubject.subscribe(onNext: {
            do {
                try localRepositoryService.reset()
            } catch {
                print("[MainViewModel] reset all repository failed : \(error.localizedDescription)")
            }
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        do {
            let fetchedRepos = try localRepositoryService.fetchPublic()
            repos.accept(fetchedRepos)
            
            if let repo = fetchedRepos.first(where: { $0.id == selectedRepo.value?.id }) {
                selectedRepo.accept(repo)
            } else if fetchedRepos.count > 0 {
                selectedRepo.accept(fetchedRepos[0])
            } else {
                selectedRepo.accept(nil)
            }
        } catch {
            print("[MainViewModel] fetchRepos failed : \(error.localizedDescription)")
        }
        
    }
    
}
