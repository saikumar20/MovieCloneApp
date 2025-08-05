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
        //applyconstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.masksToBounds = true
        MovieimageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        MovieimageView.image = nil
    }
    
    func applyconstraint() {
        NSLayoutConstraint.deactivate([
        
            self.MovieimageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.MovieimageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.MovieimageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.MovieimageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        
        ])
    }
    
    
    func databinding(imageurl : String?) {
        DispatchQueue.main.async {
            guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(describing: imageurl ?? ""))") else { return }
            self.MovieimageView.sd_setImage(with: url)
        }
       
    }
    
    
}
