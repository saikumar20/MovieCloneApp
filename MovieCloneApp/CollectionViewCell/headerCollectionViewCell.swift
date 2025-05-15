//
//  headerCollectionViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import UIKit

class headerCollectionViewCell: UICollectionViewCell {
    
    let images : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds  = true
        
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(images)
//        applyconstriaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        images.frame = contentView.bounds
    }
    
    func applyconstriaint() {
        let imagesConstraints = [images.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                 images.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                 images.topAnchor.constraint(equalTo: contentView.topAnchor),
                                 images.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        
        NSLayoutConstraint.activate(imagesConstraints)
    }
    
    
}
