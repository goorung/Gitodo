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
        let updateRepoInfo: AnyObserver<MyRepo>
    }
    
    struct Output {
        var repos: Driver<[MyRepo]>
    }
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let updateRepoInfoSubject = PublishSubject<MyRepo>()
    
    private let repos = BehaviorRelay<[MyRepo]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            viewDidLoad: viewDidLoadSubject.asObserver(),
            updateRepoInfo: updateRepoInfoSubject.asObserver()
        )
        output = Output(
            repos: repos.asDriver(onErrorJustReturn: [])
        )
        
        viewDidLoadSubject.subscribe(onNext: {[weak self] in
            self?.fetchRepos()
        }).disposed(by: disposeBag)
        
        updateRepoInfoSubject.subscribe(onNext: { [weak self] repo in
            self?.updateRepoInfo(repo)
        }).disposed(by: disposeBag)
    }
    
    private func fetchRepos() {
        Task {
            do {
                // 원격에서 레포지토리 목록 API 호출
                let fetchedRepos = try await APIManager.shared.fetchRepositories().map {
                    MyRepo.initItem(repository: $0)
                }
                // 데이터베이스 레포지토리 목록과 동기화
                TempRepository.syncRepos(fetchedRepos)
                // 결과 반영
                repos.accept(TempRepository.getRepos())
            } catch {
                print("[RepositorySettingsViewModel] fetchRepos failed : \(error.localizedDescription)")
            }
        }
    }
    
    private func updateRepoInfo(_ repo: MyRepo) {
        TempRepository.updateRepoInfo(repo)
        repos.accept(TempRepository.getRepos())
    }
    
    func repo(at indexPath: IndexPath) -> MyRepo {
        repos.value[indexPath.row]
    }
}
