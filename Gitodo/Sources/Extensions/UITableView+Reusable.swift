//
//  UITableView+Reusable.swift
//  Gitodo
//
//  Created by 지연 on 7/9/24.
//

import UIKit

extension UITableView {
    
    final func register<Cell: UITableViewCell>(cellType: Cell.Type) where Cell: Reusable {
        self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeueReusableCell<Cell: UITableViewCell>(
        for indexPath: IndexPath,
        cellType: Cell.Type = Cell.self
    ) -> Cell where Cell: Reusable {
        guard let cell = self.dequeueReusableCell(
            withIdentifier: cellType.reuseIdentifier,
            for: indexPath
        ) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)")
        }
        return cell
    }
    
}
