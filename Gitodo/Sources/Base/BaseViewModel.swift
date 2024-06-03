//
//  BaseViewModel.swift
//  Gitodo
//
//  Created by jiyeon on 5/24/24.
//

import Foundation
import RxSwift

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func bindInputs()
}
