//
//  RepositorySettingViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/8/24.
//

import Foundation

import RxCocoa
import RxSwift

final class RepositorySettingViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let updateRepo: AnyObserver<Repository>
    }
    
    struct Output {
        var repos: Driver<[Repository]>
    }
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let updateRepoSubject = PublishSubject<Repository>()
    
    private let repos = BehaviorRelay<[Repository]>(value: [])
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
    
    private func updateRepo(_ repo: Repository) {
        TempRepository.updateRepo(repo)
        fetchRepos()
    }
    
    func repo(at indexPath: IndexPath) -> Repository {
        repos.value[indexPath.row]
    }
}
