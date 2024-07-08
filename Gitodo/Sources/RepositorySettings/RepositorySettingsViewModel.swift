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
        let updateRepoOrder: AnyObserver<(IndexPath, IndexPath)>
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
    private let updateRepoOrderSubject = PublishSubject<(IndexPath, IndexPath)>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    
    private let myRepos = PublishRelay<[MyRepo]>()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    
    // MARK: - Initializer
    
    init(localRepositoryService: LocalRepositoryServiceProtocol) {
        self.localRepositoryService = localRepositoryService

        input = Input(
            fetchRepo: fetchRepoSubject.asObserver(),
            updateRepoOrder: updateRepoOrderSubject.asObserver(),
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
        
        updateRepoOrderSubject.subscribe(onNext: { [weak self] from, to in
            self?.updateRepoOrder(from, to)
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
    
    private func updateRepoOrder(_ from: IndexPath, _ to: IndexPath) {
        do {
            var currentRepos = try localRepositoryService.fetchPublic()
            let movedRepo = currentRepos.remove(at: from.row)
            currentRepos.insert(movedRepo, at: to.row)
            try self.localRepositoryService.updateOrder(of: currentRepos)
            try updateRepos()
            NotificationCenter.default.post(name: .RepositoryOrderDidUpdate, object: self)
        } catch {
            logError(in:  #function, error)
        }
    }
    
    private func updateRepoInfo(_ repo: MyRepo) {
        do {
            try localRepositoryService.updateInfo(of: repo)
            try updateRepos()
        } catch {
            logError(in:  #function, error)
        }
    }
    
    private func updateRepos() throws {
        myRepos.accept(try localRepositoryService.fetchPublic())
    }
    
    private func logError(in functionName: String, _ error: Error) {
        print("[RepositorySettingsViewModel] \(functionName) failed : \(error.localizedDescription)")
    }
    
}
