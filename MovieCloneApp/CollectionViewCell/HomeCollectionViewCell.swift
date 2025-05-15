//
//  HomeCollectionViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 07/05/25.
//

import UIKit
import SDWebImage

class HomeCollectionViewCell: UICollectionViewCell {
    
    
    let MovieimageView : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(MovieimageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        MovieimageView.frame = contentView.bounds
    }
    
    
    func databinding(imageurl : String?) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(describing: imageurl ?? ""))") else { return }
        MovieimageView.sd_setImage(with: url)
    }
    
    
}
