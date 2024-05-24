//
//  IssueInfoView.swift
//  Gitodo
//
//  Created by jiyeon on 5/4/24.
//

import SafariServices
import UIKit
import WebKit

import GitodoShared

import MarkdownView
import SkeletonView
import SnapKit

class IssueInfoView: UIView {
    
    // MARK: - UI Components
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .title2
        label.textColor = .label
        return label
    }()
    
    private lazy var labelsLabel = createLabel(withText: "Labels")
    
    private lazy var labelsView = LabelCollectionView()
    
    private lazy var assigneesLabel = createLabel(withText: "Assignees")
    
    private lazy var assigneesView = AssigneeCollectionView()
    
    private lazy var separatorView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var bodyContainerView = UIView()
    
    private lazy var markdownView = MarkdownView()
    
    private lazy var loadingTextView = {
        let textView = UITextView()
        textView.isSkeletonable = true
        textView.lastLineFillPercent = 30
        textView.linesCornerRadius = 5
        textView.skeletonTextNumberOfLines = 8
        textView.skeletonTextLineHeight = .fixed(18)
        textView.skeletonLineSpacing = 15
        return textView
    }()
    
    // MARK: - Intiaizlier
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        configureMarkdownView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(labelsLabel)
        labelsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(labelsView)
        labelsView.snp.makeConstraints { make in
            make.top.equalTo(labelsLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(assigneesLabel)
        assigneesLabel.snp.makeConstraints { make in
            make.top.equalTo(labelsView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(assigneesView)
        assigneesView.snp.makeConstraints { make in
            make.top.equalTo(assigneesLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(assigneesView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(3)
        }
        
        contentView.addSubview(bodyContainerView)
        bodyContainerView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        bodyContainerView.addSubview(markdownView)
        markdownView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(400)
        }
        
        bodyContainerView.addSubview(loadingTextView)
        loadingTextView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.horizontalEdges.equalToSuperview().inset(40)
        }
    }
    
    private func configureMarkdownView() {
        loadingTextView.showAnimatedGradientSkeleton()
        markdownView.isScrollEnabled = false
        markdownView.onRendered = { [weak self] _ in
            self?.loadingTextView.hideSkeleton()
            self?.loadingTextView.isHidden = true
            self?.updateMarkdownViewHeight()
        }
        
        markdownView.onTouchLink = { request in
            guard let url = request.url else { return false }

            if url.scheme == "http" || url.scheme == "https" {
                UIApplication.shared.canOpenURL(url)
                UIApplication.shared.open(url, options: [:])
            }
            return false
        }
    }
    
    private func updateMarkdownViewHeight() {
           if let webView = markdownView.subviews.compactMap({ $0 as? WKWebView }).first {
               webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, error in
                   if let height = result as? CGFloat {
                       self?.markdownView.snp.updateConstraints { make in
                           make.height.equalTo(height)
                       }
                   }
               }
           }
       }
    
    func configure(with issue: Issue?) {
        guard let issue = issue else { return }
        titleLabel.text = issue.title
        labelsView.configure(with: issue.labels)
        assigneesView.configure(with: issue.assignees)
    }
    
    func loadMarkdown(markdown: String?) {
        let css = """
        body { font-size: 15px; }
        code {
            font-family: monospace;
            font-size: 85%;
        }
        strong {
            font-weight: 600;
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 12px;
            margin-bottom: 8px;
            font-weight: 600;
        }
        h1 {
            font-size: 1.9em;
            border-bottom: 1px solid var(--divider-color-light);
            padding-bottom: 0.3em;
            line-height: 1.125em;
        }
        h2 {
            font-size: 1.425em;
            border-bottom: 1px solid var(--divider-color-light);
            padding-bottom: 0.3em;
            line-height: 1.125em;
        }
        h3 {
            font-size: 1.1875em;
            line-height: 1.125em;
        }
        h4 {
            font-size: 0.95em;
            line-height: 1.125em;
        }
        h5 {
            font-size: 0.83125em;
            line-height: 1.125em;
        }
        h6 {
            font-size: 0.8075em;
            line-height: 1.125em;
        }
        p {
            margin-top: 0;
            margin-bottom: 16px;
            line-height: 1.25em;
        }
        blockquote {
            display: flex;
            margin: 16px 0;
            padding: 0.5em;
            border-left: 0.2em solid var(--border-color-light);
        }
        pre {
            display: block;
            margin: 16px 0;
            padding: 16px;
            overflow-x: auto;
            border-radius: 6px;
            font-family: monospace;
            font-size: 85%;
            line-height: 1.225em;
        }
        li {
            margin-top: 0.25em;
        }
        li input[type="checkbox"] {
            margin-right: 0.5em;
            min-width: 1.5em;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 0;
            margin-bottom: 16px;
        }
        th, td {
            padding: 6px 13px;
        }
        thead th {
            font-weight: 600;
        }
        hr {
            height: 0.25em;
            margin: 24px 0;
            border: none;
        }
        """
        
        markdownView.load(markdown: markdown, css: css)
    }
    
}

extension IssueInfoView {
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .systemGray
        label.font = .calloutSB
        return label
    }
    
}
