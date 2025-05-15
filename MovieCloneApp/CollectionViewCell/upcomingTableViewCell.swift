//
//  upcomingTableViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 10/05/25.
//

import UIKit
import SDWebImage

class upcomingTableViewCell: UITableViewCell {
    
    
    let movieImage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let namelbl :  UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let buttonImage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage(systemName: "play.circle")?.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(movieImage)
        contentView.addSubview(namelbl)
        contentView.addSubview(buttonImage)
        applyconstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyconstraint() {
        
        NSLayoutConstraint.activate([movieImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),movieImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),movieImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),movieImage.widthAnchor.constraint(equalToConstant: 132)])
        
        NSLayoutConstraint.activate([namelbl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),namelbl.leadingAnchor.constraint(equalTo: movieImage.trailingAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([buttonImage.leadingAnchor.constraint(equalTo: namelbl.trailingAnchor, constant: 8),buttonImage.widthAnchor.constraint(equalToConstant: 50),buttonImage.heightAnchor.constraint(equalToConstant: 50),buttonImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),buttonImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func databinding(_ data : Movie) {
        
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(describing: data.poster_path ?? ""))")else {return}
        
        namelbl.text = data.original_title ?? data.name ?? data.original_title ?? data.title
        movieImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "play.circle"), context: nil)
        
    }
    
    func databindingForDownload(_ data : MovieDownloadData) {
        
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(describing: data.poster_path ?? ""))")else {return}
        
        namelbl.text = data.original_title ?? data.name ?? data.original_title ?? data.title
        movieImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "play.circle"), context: nil)
        
    }

}
