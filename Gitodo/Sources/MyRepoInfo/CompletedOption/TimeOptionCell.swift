//
//  TimeOptionCell.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import SnapKit

class TimeOptionCell: UITableViewCell {
    static let reuseIdentifier = "TimeOptionCell"
    
    let timeOption = ["오전", "오후"]
    let hourOption = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    
    private lazy var stackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var preLabel = {
        let label = UILabel()
        label.text = "매일"
        label.textColor = .label
        return label
    }()
    
    private lazy var timePicker = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private lazy var postLabel = {
        let label = UILabel()
        label.text = "이후"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
        
        timePicker.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
        
        stackView.addArrangedSubview(preLabel)
        stackView.addArrangedSubview(timePicker)
    }
    
}

extension TimeOptionCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeOption.count
        } else {
            return hourOption.count
        }
    }
    
}

extension TimeOptionCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return timeOption[row]
        } else {
            return hourOption[row]
        }
    }
}
