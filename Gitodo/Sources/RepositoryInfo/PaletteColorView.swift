//
//  PaletteColorView.swift
//  Gitodo
//
//  Created by jiyeon on 4/27/24.
//

import UIKit

protocol PaletteColorDelegate: AnyObject {
    func selectColor(_ color: PaletteColor)
}

class PaletteColorView: UICollectionView {
    
    weak var colorDelegate: PaletteColorDelegate?
    
    private let itemsPerRow: CGFloat = 6.0
    private let spacing: CGFloat = 5.0

    
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
        self.delegate = self
        self.dataSource = self
        self.register(PaletteColorCell.self, forCellWithReuseIdentifier: PaletteColorCell.reuseIdentifier)
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaletteColorCell else { return }
        cell.highlightCell()
        colorDelegate?.selectColor(PaletteColor.allCases[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaletteColorCell else { return }
        cell.unhighlightCell()
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
        return cell
    }
    
}
