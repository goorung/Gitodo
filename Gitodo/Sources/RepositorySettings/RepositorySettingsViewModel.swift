//
//  RepositorySettingsViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/8/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxSwift

final class RepositorySettingsViewModel: BaseViewModel {
    
    struct Input {
        let fetchRepo: AnyObserver<Void>
        let updateRepoOrder: AnyObserver<Void>
        let togglePublic: AnyObserver<MyRepo>
        let updateRepoInfo: AnyObserver<MyRepo>
        let removeRepo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
        var publicRepos: Driver<[MyRepo]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let fetchRepoSubject = PublishSubject<Void>()
    private let updateRepoOrderSubject = PublishSubject<Void>()
    private let togglePublicSubject = PublishSubject<MyRepo>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    private let removeRepoSubject = PublishSubject<MyRepo>()
    
    private let repos = PublishRelay<[MyRepo]>()
    private let publicRepos = PublishRelay<[MyRepo]>()
    private let isLoading = PublishRelay<Bool>()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    // MARK: - Initializer
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService

        input = Input(
            fetchRepo: fetchRepoSubject.asObserver(), 
            updateRepoOrder: updateRepoOrderSubject.asObserver(),
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
    
    func bindInputs() {
        fetchRepoSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        updateRepoOrderSubject.subscribe (onNext: { [weak self] in
            guard let self else { return }
            do {
                publicRepos.accept(try self.localRepositoryService.fetchPublic())
            } catch {
                logError(in: "updateRepoOrder", error)
            }
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
                let allRepos = try await APIManager.shared.fetchRepositories().map {
                    MyRepo.initItem(repository: $0)
                }
                try localRepositoryService.sync(with: allRepos)
            } catch {
                logError(in: "fetchRepos", error)
            }
            try updateRepos()
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
