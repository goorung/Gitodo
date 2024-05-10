//
//  RepositorySettingsViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/8/24.
//

import Foundation

import RxCocoa
import RxSwift

final class RepositorySettingsViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let updateRepo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
    }
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let updateRepoSubject = PublishSubject<MyRepo>()
    
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            viewDidLoad: viewDidLoadSubject.asObserver(),
            updateRepo: updateRepoSubject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: [])
        )
        
        viewDidLoadSubject.subscribe(onNext: {[weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        updateRepoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepo(repo)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        let fetchedRepos = TempRepository.getRepos()
        repos.accept(fetchedRepos)
    }
    
    private func updateRepo(_ repo: MyRepo) {
        TempRepository.updateRepo(repo)
        fetchRepos()
    }
    
    func repo(at indexPath: IndexPath) -> MyRepo {
        repos.value[indexPath.row]
    }
}
