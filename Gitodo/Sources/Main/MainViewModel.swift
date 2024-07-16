//
//  MainViewModel.swift
//  Gitodo
//
//  Created by 이지현 on 5/3/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxSwift

final class MainViewModel: BaseViewModel {
    
    struct Input {
        let viewWillAppear: AnyObserver<Void>
        let selectRepoID: AnyObserver<Int>
        let selectRepoIndex: AnyObserver<Int>
        let updateRepoInfo: AnyObserver<MyRepo>
        let hideRepo: AnyObserver<MyRepo>
        let resetAllRepository: AnyObserver<Void>
        let deleteCompletedTodos: AnyObserver<Void>
    }
    
    struct Output {
        var selectedRepo: Driver<MyRepo?>
        var repos: Driver<[MyRepo]>
        var hideDisabled: Driver<Void>
        var refreshTodos: Driver<Void>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let selectRepoIndexSubject = PublishSubject<Int>()
    private let selectRepoIDSubject = PublishSubject<Int>()
    private let resetAllRepositorySubject = PublishSubject<Void>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    private let hideRepoSubject = PublishSubject<MyRepo>()
    private let deleteCompletedTodosSubject = PublishSubject<Void>()
    
    private var selectedRepo = BehaviorRelay<MyRepo?>(value: nil)
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    private let hideDisabled = PublishRelay<Void>()
    private let refreshTodos = PublishRelay<Void>()
    
    private let localRepositoryService: LocalRepositoryServiceProtocol
    private let localTodoService: LocalTodoServiceProtocol
    
    // MARK: - Initializer
    
    init(localRepositoryService: LocalRepositoryServiceProtocol, localTodoService: LocalTodoServiceProtocol) {
        self.localRepositoryService = localRepositoryService
        self.localTodoService = localTodoService
        
        input = Input(
            viewWillAppear: viewWillAppearSubject.asObserver(), 
            selectRepoID: selectRepoIDSubject.asObserver(),
            selectRepoIndex: selectRepoIndexSubject.asObserver(),
            updateRepoInfo: updateRepoInfoSubject.asObserver(),
            hideRepo: hideRepoSubject.asObserver(),
            resetAllRepository: resetAllRepositorySubject.asObserver(),
            deleteCompletedTodos: deleteCompletedTodosSubject.asObserver()
        )
        
        output = Output(
            selectedRepo: selectedRepo.asDriver(onErrorJustReturn: nil),
            repos: repos.asDriver(onErrorJustReturn: []),
            hideDisabled: hideDisabled.asDriver(onErrorJustReturn: ()),
            refreshTodos: refreshTodos.asDriver(onErrorJustReturn: ())
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        viewWillAppearSubject.subscribe(onNext: { [weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        selectRepoIDSubject.subscribe(onNext: { [weak self] id in
            let repo = self?.repos.value.first{ $0.id == id }
            self?.selectedRepo.accept(repo)
        }).disposed(by: disposeBag)
        
        selectRepoIndexSubject.subscribe(onNext: { [weak self] index in
            let repo = self?.repos.value[index]
            self?.selectedRepo.accept(repo)
        }).disposed(by: disposeBag)
        
        resetAllRepositorySubject.subscribe(onNext: { [weak self] in
            do {
                try self?.localRepositoryService.reset()
            } catch {
                print("[MainViewModel] reset all repository failed : \(error.localizedDescription)")
            }
        }).disposed(by: disposeBag)
        
        updateRepoInfoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepoInfo(repo)
        }).disposed(by: disposeBag)
        
        hideRepoSubject.subscribe(onNext: { [weak self] repo in
            self?.hideRepo(repo)
        }).disposed(by: disposeBag)
        
        deleteCompletedTodosSubject.subscribe(onNext:  { [weak self] in
            self?.deleteCompletedTodos()
        }).disposed(by: disposeBag)
    }
    
    private func deleteCompletedTodos() {
        do {
            guard let repoId = selectedRepo.value?.id else { return }
            try localTodoService.deleteCompletedTodos(in: repoId)
            refreshTodos.accept(())
        } catch {
            print("[MainViewModel] deleteCompletedTodos failed : \(error.localizedDescription)")
        }
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
    
    private func updateRepoInfo(_ repo: MyRepo) {
        do {
            try localRepositoryService.updateInfo(of: repo)
            fetchRepos()
        } catch {
            logError(in: "updateRepoInfo", error)
        }
    }
    
    private func hideRepo(_ repo: MyRepo) {
        if repos.value.count == 1 {
            hideDisabled.accept(())
            return
        }
        
        do {
            try localRepositoryService.hideRepository(repo)
            fetchRepos()
        } catch {
            logError(in: "hideRepo", error)
        }
    
    }
    
    private func logError(in functionName: String, _ error: Error) {
        print("[MainViewModel] \(functionName) failed : \(error.localizedDescription)")
    }
    
}
