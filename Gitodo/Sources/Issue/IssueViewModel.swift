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

final class IssueViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let setRepo: AnyObserver<MyRepo>
        let fetchIssue: AnyObserver<Void>
    }
    
    struct Output {
        var issues: Driver<[Issue]>
        var isLoading: Driver<Bool>
    }
    
    private let setRepoSubject = PublishSubject<MyRepo>()
    private let fetchIssueSubject = PublishSubject<Void>()
    
    private let issues = BehaviorRelay<[Issue]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    private var currentRepo: MyRepo?
    
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            setRepo: setRepoSubject.asObserver(),
            fetchIssue: fetchIssueSubject.asObserver()
        )
        output = Output(
            issues: issues.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        setRepoSubject.subscribe(onNext: { [weak self] repo in
            self?.currentRepo = repo
            self?.fetchIssue()
        }).disposed(by: disposeBag)
        
        fetchIssueSubject.subscribe(onNext: { [weak self] in
            self?.fetchIssue()
        }).disposed(by: disposeBag)
    }
    
    private func fetchIssue() {
        isLoading.accept(true)
        guard let repo = currentRepo else { return }
        Task {
            do {
                let fetchedIssue = try await APIManager.shared.fetchIssues(for: repo)
                issues.accept(fetchedIssue.filter { $0.pullRequest == nil })
            } catch {
                print("[IssueViewModel] fetchIssue failed : \(error.localizedDescription)")
                issues.accept([])
            }
            isLoading.accept(false)
        }
    }
    
    func issue(at indexPath: IndexPath) -> Issue {
        return issues.value[indexPath.row]
    }
    
}
