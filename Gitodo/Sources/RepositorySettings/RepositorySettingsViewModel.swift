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
        let fetchRepo: AnyObserver<Void>
        let togglePublic: AnyObserver<MyRepo>
        let updateRepoInfo: AnyObserver<MyRepo>
        let removeRepo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
        var publicRepos: Driver<[MyRepo]>
        var isLoading: Driver<Bool>
    }
    
    private let fetchRepoSubject = PublishSubject<Void>()
    private let togglePublicSubject = PublishSubject<MyRepo>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    private let removeRepoSubject = PublishSubject<MyRepo>()
    
    private let repos = PublishRelay<[MyRepo]>()
    private let publicRepos = PublishRelay<[MyRepo]>()
    private let isLoading = PublishRelay<Bool>()
    
    private let disposeBag = DisposeBag()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService

        input = Input(
            fetchRepo: fetchRepoSubject.asObserver(),
            togglePublic: togglePublicSubject.asObserver(),
            updateRepoInfo: updateRepoInfoSubject.asObserver(),
            removeRepo: removeRepoSubject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: []),
            publicRepos: publicRepos.asDriver(onErrorJustReturn: []),
            isLoading: isLoading.asDriver(onErrorJustReturn: false)
        )
        
        bindInputs() 
    }
    
    private func bindInputs() {
        fetchRepoSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        togglePublicSubject.subscribe(onNext: { [weak self] repo in
            self?.togglePublic(repo)
        }).disposed(by: disposeBag)
        
        updateRepoInfoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepoInfo(repo)
        }).disposed(by: disposeBag)
        
        removeRepoSubject.subscribe(onNext: { [weak self] id in
            self?.removeRepo(id)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        isLoading.accept(true)
        Task {
            do {
                let fetchedRepos = try await APIManager.shared.fetchRepositories().map {
                    MyRepo.initItem(repository: $0)
                }
                try localRepositoryService.sync(with: fetchedRepos)
                try updateRepos()
            } catch {
                logError(in: "fetchRepos", error)
            }
            isLoading.accept(false)
        }
    }
    
    private func togglePublic(_ repo: MyRepo) {
        do {
            try localRepositoryService.togglePublicStatus(of: repo)
            try updateRepos()
        } catch {
            logError(in: "togglePublic", error)
        }
        
    }
    
    private func updateRepoInfo(_ repo: MyRepo) {
        do {
            try localRepositoryService.updateInfo(of: repo)
            try updateRepos()
        } catch {
            logError(in: "updateRepoInfo", error)
        }
    }
    
    private func removeRepo(_ repo: MyRepo) {
        do {
            try localRepositoryService.delete(repo)
            try updateRepos()
        } catch {
            logError(in: "removeRepo", error)
        }
        
    }
    
    private func updateRepos() throws {
        repos.accept(try localRepositoryService.fetchAll())
        publicRepos.accept(try localRepositoryService.fetchPublic())
    }
    
    private func logError(in functionName: String, _ error: Error) {
        print("[RepositorySettingsViewModel] \(functionName) failed : \(error.localizedDescription)")
    }
}
