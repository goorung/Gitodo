//
//  SelfSizingTableView.swift
//  Gitodo
//
//  Created by 이지현 on 7/25/24.
//

import UIKit

class SelfSizingTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        contentSize
    }
}
