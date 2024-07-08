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
        let updateRepoInfo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var myRepos: Driver<[MyRepo]>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let fetchRepoSubject = PublishSubject<Void>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    
    private let myRepos = PublishRelay<[MyRepo]>()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    // MARK: - Initializer
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService

        input = Input(
            fetchRepo: fetchRepoSubject.asObserver(), 
            updateRepoInfo: updateRepoInfoSubject.asObserver()
        )
        
        output = Output(
            myRepos: myRepos.asDriver(onErrorJustReturn: [])
        )
        
        bindInputs() 
    }
    
    func bindInputs() {
        fetchRepoSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        updateRepoInfoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepoInfo(repo)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        do {
            try updateRepos()
        } catch {
            logError(in: #function, error)
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
    
    private func updateRepos() throws {
        myRepos.accept(try localRepositoryService.fetchPublic())
    }
    
    private func logError(in functionName: String, _ error: Error) {
        print("[RepositorySettingsViewModel] \(functionName) failed : \(error.localizedDescription)")
    }
    
}
