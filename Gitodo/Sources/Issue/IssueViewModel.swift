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
    
    private let setCurrentRepoSubject = PublishSubject<MyRepo>()
    private let fetchIssueSubject = PublishSubject<Void>()
    
    private let issues = BehaviorRelay<[Issue]>(value: [])
    private let issueState = BehaviorRelay<IssueState>(value: .hasIssues)
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    private var currentRepo: MyRepo?
    
    // MARK: - Initializer
    
    init() {
        input = Input(
            setCurrentRepo: setCurrentRepoSubject.asObserver(),
            fetchIssue: fetchIssueSubject.asObserver()
        )
        
        output = Output(
            issues: issues.asDriver(),
            issueState: issueState.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        setCurrentRepoSubject.subscribe(onNext: { [weak self] repo in
            self?.currentRepo = repo
            self?.fetchIssue()
        }).disposed(by: disposeBag)
        
        fetchIssueSubject.subscribe(onNext: { [weak self] in
            self?.fetchIssue()
        }).disposed(by: disposeBag)
    }
    
    private func fetchIssue() {
        guard let repo = currentRepo else { return }
        if repo.isDeleted {
            updateIssues(state: .repoDeleted)
        } else {
            handleActiveRepo(repo: repo)
        }
    }
    
    private func handleActiveRepo(repo: MyRepo) {
        Task {
            do {
                let allIssues = try await APIManager.shared.fetchIssues(for: repo)
                let issuesWithoutPR = allIssues.filter { $0.pullRequest == nil }
                if issuesWithoutPR.isEmpty {
                    updateIssues(with: issuesWithoutPR, state: .noIssues)
                } else {
                    updateIssues(with: issuesWithoutPR, state: .hasIssues)
                }
                
            } catch let error as URLError {
                print("[IssueViewModel] fetchIssue failed : \(error.localizedDescription)")
                if error.code == .notConnectedToInternet {
                    updateIssues(state: .noInternetConnection)
                } else {
                    updateIssues(state: .error)
                }
            }
            isLoading.accept(false)
        }
    }
    
    private func updateIssues(with issues: [Issue] = [], state: IssueState) {
        self.issues.accept(issues)
        self.issueState.accept(state)
    }
    
    func issue(at indexPath: IndexPath) -> Issue {
        return issues.value[indexPath.row]
    }
    
}
