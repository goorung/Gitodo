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
        let togglePublic: AnyObserver<Int>
        let updateRepoInfo: AnyObserver<MyRepo>
        let removeRepo: AnyObserver<Int>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
    }
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let togglePublicSubject = PublishSubject<Int>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    private let removeRepoSuject = PublishSubject<Int>()
    
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            viewDidLoad: viewDidLoadSubject.asObserver(),
            togglePublic: togglePublicSubject.asObserver(),
            updateRepoInfo: updateRepoInfoSubject.asObserver(),
            removeRepo: removeRepoSuject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: [])
        )
        
        viewDidLoadSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        togglePublicSubject.subscribe(onNext: { [weak self] id in
            self?.togglePublic(id)
        }).disposed(by: disposeBag)
        
        updateRepoInfoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepoInfo(repo)
        }).disposed(by: disposeBag)
        
        removeRepoSuject.subscribe(onNext: { [weak self] id in
            self?.removeRepo(id)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        Task {
            do {
                let fetchedRepos = try await APIManager.shared.fetchRepositories().map {
                    MyRepo.initItem(repository: $0)
                }
                TempRepository.syncRepos(fetchedRepos)
                repos.accept(sortedRepos())
            } catch {
                print("[RepositorySettingsViewModel] fetchRepos failed : \(error.localizedDescription)")
            }
        }
    }
    
    private func togglePublic(_ id: Int) {
        TempRepository.togglePublic(id)
        repos.accept(sortedRepos())
    }
    
    private func updateRepoInfo(_ repo: MyRepo) {
        TempRepository.updateRepoInfo(repo)
        repos.accept(sortedRepos())
    }
    
    private func sortedRepos() -> [MyRepo] {
        return TempRepository.getRepos().sorted {
            $0.isPublic && !$1.isPublic
        }
    }
    
    private func removeRepo(_ id: Int) {
        TempRepository.removeRepo(id)
        repos.accept(sortedRepos())
    }
}
