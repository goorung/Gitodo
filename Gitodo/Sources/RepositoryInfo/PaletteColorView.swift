//
//  PaletteColorView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

import GitodoShared

protocol PaletteColorDelegate: AnyObject {
    func selectColor(_ color: PaletteColor)
}

final class PaletteColorView: UICollectionView {
    
    weak var colorDelegate: PaletteColorDelegate?
    
    private let itemsPerRow: CGFloat = 6.0
    private let spacing: CGFloat = 5.0
    private var selectedIndex: Int?
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        setupProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupProperty() {
        delegate = self
        dataSource = self
        register(PaletteColorCell.self, forCellWithReuseIdentifier: PaletteColorCell.reuseIdentifier)
        backgroundColor = .background
    }
    
    func setInitialColor(_ hex: UInt) {
        selectedIndex = PaletteColor.findIndex(hex)
        reloadData()
    }
    
}

extension PaletteColorView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = spacing * (itemsPerRow - 1) * 2
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
}

extension PaletteColorView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 이전 선택된 셀 unhighlight
        if let selectedIndex = selectedIndex,
           let cell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? PaletteColorCell {
            cell.unhighlightCell()
        }
        // 새로 선택된 셀 highlight
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaletteColorCell else { return }
        cell.highlightCell()
        selectedIndex = indexPath.row
        
        colorDelegate?.selectColor(PaletteColor.allCases[indexPath.row])
    }
    
}

extension PaletteColorView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PaletteColor.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaletteColorCell.reuseIdentifier, for: indexPath) as? PaletteColorCell else {
            fatalError("Unable to dequeue PaletteColorCell")
        }
        let color = PaletteColor.allCases[indexPath.row]
        cell.configure(with: UIColor(hex: color.hex))
        if indexPath.row == selectedIndex {
            cell.highlightCell()
        }
        return cell
    }
    
}
