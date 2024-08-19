//
//  DeletionOptionCell.swift
//  GitodoShared
//
//  Created by 이지현 on 7/23/24.
//

import UIKit

import GitodoShared

import SnapKit

protocol DeletionOptionCellDelegate: AnyObject {
    func deletionTimeChanged(_ deletionOption: DeletionOption)
}

class DeletionOptionCell: UITableViewCell {
    
    static let reuseIdentifier = "DeletionOptionCell"
    weak var delegate: DeletionOptionCellDelegate?
    private var deletionOption: DeletionOption = .none
    
    // MARK: - UI Components
    
    private lazy var containerStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var checkableLabelView = UIView()
    
    private lazy var labelStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.font = .bodySB
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var timeOptionLabel = {
        let label = UILabel()
        label.font = .smallBody
        label.isHidden = true
        label.text = ""
        return label
    }()
    
    private lazy var selectedButton = {
        let button = UIButton()
        button.isHidden = true
        button.tintColor = .label
        button.isUserInteractionEnabled = false
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "checkmark")
        button.configuration?.preferredSymbolConfigurationForImage = .init(pointSize: 10.0, weight: .bold)
        return button
    }()
    
    private lazy var datePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .time
        picker.minuteInterval = 5
        picker.locale = Locale(identifier: "ko_KR")
        picker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        selectedButton.isHidden = true
        timeOptionLabel.isHidden = true
        datePicker.isHidden = true
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupContainerStackView()
    
    }
    
    private func setupContainerStackView() {
        containerStackView.addArrangedSubview(checkableLabelView)
        checkableLabelView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        setupCheckableLabelView()
        
        containerStackView.addArrangedSubview(datePicker)
    }
    
    private func setupCheckableLabelView() {
        checkableLabelView.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(timeOptionLabel)
        
        checkableLabelView.addSubview(selectedButton)
        selectedButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
    func configure(option: DeletionOption, selectedOption: DeletionOption) {
        deletionOption = option
        let isSelected = option.id == selectedOption.id
        switch deletionOption {
        case .none:
            nameLabel.text = "삭제 안 함"
        case .immediate:
            nameLabel.text = "바로 삭제"
        case .scheduledDaily:
            nameLabel.text = "매일 특정 시간 삭제"
            if isSelected {
                guard let date = convertScheduledDailyTimeToDate(option: selectedOption) else { break }
                timeOptionLabel.isHidden = false
                timeOptionLabel.text = convertToString(date: date)
                datePicker.isHidden = false
                datePicker.date = date
            }
        case .afterDuration:
            nameLabel.text = "특정 시간 이후 삭제"
        }
        
        if isSelected {
            selectedButton.isHidden = false
        }
    }
    
    private func convertScheduledDailyTimeToDate(option: DeletionOption) -> Date? {
        switch option {
        case .scheduledDaily(let hour, let minute):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.date(from: "\(hour):\(minute)")
        default: return nil
        }
    }
    
    private func convertToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        return dateFormatter.string(from: date)
    }
    
    @objc private func timeChanged(sender: UIDatePicker) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: sender.date)
        guard let hour = components.hour, let minute = components.minute  else { return }

        delegate?.deletionTimeChanged(.scheduledDaily(hour: hour, minute: minute))
        timeOptionLabel.text = convertToString(date: sender.date)
    }
    
}
 
