//
//  scrollCollectionViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 09/05/25.
//

import UIKit
import SDWebImage

class scrollCollectionViewCell: UICollectionViewCell {
    
    var scrollimage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollimage)
        applyConstratin()
    }
    
    func applyConstratin() {
        let imageConstraint = [scrollimage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),scrollimage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),scrollimage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),scrollimage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)]
        NSLayoutConstraint.activate(imageConstraint)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func databinding(_ data : String?) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(describing: data ?? ""))") else { return }
        scrollimage.sd_setImage(with: url, placeholderImage: UIImage(named: ""), context: nil)
        
    }
    
}
