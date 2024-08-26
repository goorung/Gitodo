//
//  IssueViewModel.swift
//  Gitodo
//
//  Created by jiyeon on 5/10/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxRelay
import RxSwift

final class IssueViewModel: BaseViewModel {
    
    struct Input {
        let setCurrentRepo: AnyObserver<MyRepo>
        let fetchIssue: AnyObserver<Void>
        let fetchMoreIssue: AnyObserver<Void>
    }
    
    struct Output {
        var issues: Driver<[Issue]>
        var issueState: Driver<IssueState>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let setCurrentRepo = PublishSubject<MyRepo>()
    private let fetchIssue = PublishSubject<Void>()
    private let fetchMoreIssue = PublishSubject<Void>()
    
    private let issues = BehaviorRelay<[Issue]>(value: [])
    private let issueState = BehaviorRelay<IssueState>(value: .hasIssues)
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    private var currentRepo: MyRepo?
    private var currentPage = 1
    private var fetchFlag = false
    
    // MARK: - Initializer
    
    init() {
        input = Input(
            setCurrentRepo: setCurrentRepo.asObserver(),
            fetchIssue: fetchIssue.asObserver(),
            fetchMoreIssue: fetchMoreIssue.asObserver()
        )
        
        output = Output(
            issues: issues.asDriver(),
            issueState: issueState.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        setCurrentRepo.subscribe(onNext: { [weak self] repo in
            self?.currentRepo = repo
            self?.fetchIssue(isInitialFetch: true)
        }).disposed(by: disposeBag)
        
        fetchIssue.subscribe(onNext: { [weak self] in
            self?.fetchIssue(isInitialFetch: true)
        }).disposed(by: disposeBag)
        
        fetchMoreIssue.subscribe(onNext: { [weak self] in
            self?.fetchIssue()
        }).disposed(by: disposeBag)
    }
    
    private func fetchIssue(isInitialFetch: Bool = false) {
        guard let repo = currentRepo else { return }
        if repo.isDeleted {
            updateIssuesWithError(state: .repoDeleted)
        } else {
            handleActiveRepo(repo: repo, isInitialFetch: isInitialFetch)
        }
    }
    
    private func handleActiveRepo(repo: MyRepo, isInitialFetch: Bool) {
        Task {
            do {
                if isInitialFetch {
                    isLoading.accept(true)
                    fetchFlag = false
                    currentPage = 1
                }
                
                if fetchFlag { return }
                fetchFlag = true
                
                let allIssues = try await APIManager.shared.fetchIssues(
                    for: repo,
                    page: currentPage
                )
                let issuesWithoutPR = allIssues.filter { $0.pullRequest == nil }
                
                updateIssues(with: issuesWithoutPR, isInitialFetch: isInitialFetch)
                
                fetchFlag = false
                currentPage += 1
            } catch let error as URLError {
                print("[IssueViewModel] fetchIssue failed : \(error.localizedDescription)")
                if error.code == .notConnectedToInternet {
                    updateIssuesWithError(state: .noInternetConnection)
                } else {
                    updateIssuesWithError(state: .error)
                }
            }
            if isInitialFetch {
                isLoading.accept(false)
            }
        }
    }
    
    private func updateIssues(
        with issueList: [Issue] = [],
        isInitialFetch: Bool = true
    ) {
        if isInitialFetch {
            issues.accept(issueList)
            issueList.isEmpty ?
            issueState.accept(.noIssues) :
            issueState.accept(.hasIssues)
        } else if !isInitialFetch && issueList.isEmpty {
            return
        } else {
            var updatedIssues = issues.value
            updatedIssues.append(contentsOf: issueList)
            issues.accept(updatedIssues)
        }
    }
    
    private func updateIssuesWithError(state: IssueState) {
        issues.accept([])
        issueState.accept(state)
    }
    
    func issue(at indexPath: IndexPath) -> Issue {
        return issues.value[indexPath.row]
    }
    
}
