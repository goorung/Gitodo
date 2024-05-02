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
    
    private let itemsPerRow: CGFloat = 6
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

    
    // MARK: - Initializer
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.delegate = self
        self.dataSource = self
        self.register(PaletteColorCell.self, forCellWithReuseIdentifier: PaletteColorCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PaletteColorView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
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
        cell.configure(withColor: UIColor(hex: color.hex))
        return cell
    }
    
}
