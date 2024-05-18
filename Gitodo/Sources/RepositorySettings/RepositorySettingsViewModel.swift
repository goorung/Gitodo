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
        let togglePublic: AnyObserver<MyRepo>
        let updateRepoInfo: AnyObserver<MyRepo>
        let removeRepo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
        var publicRepos: Driver<[MyRepo]>
    }
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let togglePublicSubject = PublishSubject<MyRepo>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    private let removeRepoSuject = PublishSubject<MyRepo>()
    
    private let repos = PublishRelay<[MyRepo]>()
    private let publicRepos = PublishRelay<[MyRepo]>()
    private let disposeBag = DisposeBag()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService

        input = Input(
            viewDidLoad: viewDidLoadSubject.asObserver(),
            togglePublic: togglePublicSubject.asObserver(),
            updateRepoInfo: updateRepoInfoSubject.asObserver(),
            removeRepo: removeRepoSuject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: []),
            publicRepos: publicRepos.asDriver(onErrorJustReturn: [])
        )
        
        viewDidLoadSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        togglePublicSubject.subscribe(onNext: { [weak self] repo in
            self?.togglePublic(repo)
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
                localRepositoryService.sync(with: fetchedRepos)
                updateRepos()
            } catch {
                print("[RepositorySettingsViewModel] fetchRepos failed : \(error.localizedDescription)")
            }
        }
    }
    
    private func togglePublic(_ repo: MyRepo) {
        localRepositoryService.togglePublicStatus(of: repo)
        updateRepos()
    }
    
    private func updateRepoInfo(_ repo: MyRepo) {
        localRepositoryService.updateInfo(of: repo)
        updateRepos()
    }
    
    private func removeRepo(_ repo: MyRepo) {
        localRepositoryService.remove(repo)
        updateRepos()
    }
    
    private func updateRepos() {
        repos.accept(localRepositoryService.fetchAll())
        publicRepos.accept(localRepositoryService.fetchPublic())
    }
}
