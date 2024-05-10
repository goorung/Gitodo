//
//  IssueViewModel.swift
//  Gitodo
//
//  Created by jiyeon on 5/10/24.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

final class IssueViewModel {
    let input: Input
    let output: Output
    
    struct Input {
        let fetchIssue: AnyObserver<MyRepo>
    }
    
    struct Output {
        var issues: Driver<[Issue]>
    }
    
    private let fetchIssueSuject = PublishSubject<MyRepo>()
    
    private let issues = BehaviorRelay<[Issue]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            fetchIssue: fetchIssueSuject.asObserver()
        )
        output = Output(
            issues: issues.asDriver(onErrorJustReturn: [])
        )
        
        fetchIssueSuject.subscribe(onNext: { [weak self] repo in
            self?.fetchIssue(repo)
        }).disposed(by: disposeBag)
    }
    
    private func fetchIssue(_ repo: MyRepo) {
        Task {
            do {
                let fetchedIssue = try await APIManager.shared.fetchIssues(for: repo)
                issues.accept(fetchedIssue)
            } catch {
                print("[IssueViewModel] fetchIssue failed : \(error.localizedDescription)")
                issues.accept([])
            }
        }
    }
    
    func issue(at indexPath: IndexPath) -> Issue {
        return issues.value[indexPath.row]
    }
    
}
