//
//  OrganizationViewModel.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import Foundation

import GitodoShared

import RxCocoa
import RxSwift

final class OrganizationViewModel: BaseViewModel {
    
    struct Input {
        let fetchOrganizations: AnyObserver<Void>
        let fetchMoreOrganizations: AnyObserver<Void>
    }
    
    struct Output {
        var organizations: Driver<[Organization]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let fetchOrganizations = PublishSubject<Void>()
    private let fetchMoreOrganizations = PublishSubject<Void>()
    
    private let organizations = BehaviorRelay<[Organization]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    private var me: String?
    private var currentPage = 1
    private var fetchFlag = false
    
    // MARK: - Initializer
    
    init() {
        input = Input(
            fetchOrganizations: fetchOrganizations.asObserver(),
            fetchMoreOrganizations: fetchMoreOrganizations.asObserver()
        )
        
        output = Output(
            organizations: organizations.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        fetchOrganizations.subscribe(onNext: { [weak self] in
            self?.fetchOrganizations(isInitialFetch: true)
        }).disposed(by: disposeBag)
        
        fetchMoreOrganizations.subscribe(onNext: { [weak self] in
            self?.fetchOrganizations()
        }).disposed(by: disposeBag)
    }
    
    private func fetchOrganizations(isInitialFetch: Bool = false) {
        Task {
            do {
                if fetchFlag { return }
                fetchFlag = true
                
                let fetchedOrganizations = try await APIManager.shared.fetchOrganizations(
                    page: currentPage
                )
                if !isInitialFetch && fetchedOrganizations.isEmpty { return }
                
                if isInitialFetch {
                    let me = try await APIManager.shared.fetchMe()
                    let orgnizationList = [me.asOrganization()] + fetchedOrganizations
                    organizations.accept(orgnizationList)
                } else {
                    var updatedOrganizations = organizations.value
                    updatedOrganizations.append(contentsOf: fetchedOrganizations)
                    organizations.accept(updatedOrganizations)
                }
                
                fetchFlag = false
                currentPage += 1
            } catch let error {
                print("[OrganizationViewModel] fetchOrganizations failed : \(error)")
            }
            if isInitialFetch {
                isLoading.accept(false)
            }
        }
    }
    
    func getRepositoryOwner(at indexPath: IndexPath) -> Organization {
        return organizations.value[indexPath.row]
    }
    
}
