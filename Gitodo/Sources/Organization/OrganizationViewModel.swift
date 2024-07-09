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
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
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
        isLoading.accept(true)
        Task {
            do {
                let orgnizationList = try await APIManager.shared.fetchOrganizations()
                organizations.accept(orgnizationList)
            } catch let error {
                print("fetch organizations failed : \(error)")
            }
            isLoading.accept(false)
        }
    }
    
}
