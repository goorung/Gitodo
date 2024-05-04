//
//  IssueTableView.swift
//  Gitodo
//
//  Created by jiyeon on 5/3/24.
//

import UIKit

protocol IssueDelegate: AnyObject {
    func presentInfoViewController(issue: Issue)
}

class IssueTableView: UITableView {
    
    private var issues: [Issue]? {
        didSet {
            reloadData()
        }
    }
    
    weak var issueDelegate: IssueDelegate?
    
    // MARK: - Initializer
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setupProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        delegate = self
        dataSource = self
        register(IssueCell.self, forCellReuseIdentifier: IssueCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeightChange), name: NSNotification.Name("LabelCollectionViewHeightUpdated"), object: nil)
    }
    
    @objc private func handleHeightChange(notification: Notification) {
        guard notification.object is LabelCollectionView else { return }
        
        UIView.performWithoutAnimation { [weak self] in
            self?.beginUpdates()
            self?.endUpdates()
        }
    }
    
    func configure(with issues: [Issue]?) {
        self.issues = issues
    }
    
}

extension IssueTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let issues = issues else { return }
        issueDelegate?.presentInfoViewController(issue: issues[indexPath.row])
    }
    
}

extension IssueTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let issues = issues else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IssueCell.reuseIdentifier) as? IssueCell else {
            fatalError("Unable to dequeue IssueCell")
        }
        cell.configure(with: issues[indexPath.row])
        return cell
    }
    
}
