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
        let viewDidLoad: AnyObserver<Void>
    }
    
    struct Output {
        var organizations: Driver<[Organization]>
        var isLoading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    let input: Input
    let output: Output
    
    private let viewDidLoad = PublishSubject<Void>()
    
    private let organizations = BehaviorRelay<[Organization]>(value: [])
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    private var me: String?
    
    // MARK: - Initializer
    
    init() {
        input = Input(
            viewDidLoad: viewDidLoad.asObserver()
        )
        
        output = Output(
            organizations: organizations.asDriver(),
            isLoading: isLoading.asDriver()
        )
        
        bindInputs()
    }
    
    func bindInputs() {
        viewDidLoad.subscribe(onNext: { [weak self] in
            self?.fetchOrganizations()
        }).disposed(by: disposeBag)
    }
    
    private func fetchOrganizations() {
        Task {
            do {
                let me = try await APIManager.shared.fetchMe()
                let fetchedOrganizations = try await APIManager.shared.fetchOrganizations()
                let orgnizationList = [me.asOrganization()] + fetchedOrganizations
                organizations.accept(orgnizationList)
            } catch let error {
                print("[OrganizationViewModel] fetchOrganizations failed : \(error)")
            }
            isLoading.accept(false)
        }
    }
    
    func getRepositoryOwner(at indexPath: IndexPath) -> Organization {
        return organizations.value[indexPath.row]
    }
    
}
