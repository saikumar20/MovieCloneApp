//
//  homeHeaderView.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import UIKit
import SDWebImage

class homeHeaderView: UIView {
    
    var movieList : [Movie]? {
        didSet {
            DispatchQueue.main.async {
                self.colletionview.reloadData()
                self.pageController.numberOfPages = self.movieList?.count ?? 0
            }
            
        }
    }
    
    let colletionview : UICollectionView = {
        let collectionviewlayout = UICollectionViewFlowLayout()
        collectionviewlayout.scrollDirection = .horizontal
        collectionviewlayout.minimumLineSpacing = 0
        collectionviewlayout.minimumInteritemSpacing = 0
        collectionviewlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: collectionviewlayout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.register(headerCollectionViewCell.self, forCellWithReuseIdentifier: "headerCollectionViewCell")
        return collectionview
    }()
    
    let pageController : UIPageControl = {
        let controller = UIPageControl()
        controller.currentPage = 0
        controller.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(colletionview)
        addSubview(pageController)
        colletionview.delegate = self
        colletionview.dataSource = self
        applyconstraint()
        applygradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colletionview.frame = self.bounds

        
        if let flowLayout = self.colletionview.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: bounds.width, height: 300)
        }

    }
    
    func applygradient() {
        
        let layers = CAGradientLayer()
        layers.colors = [UIColor.clear.cgColor,UIColor.systemBackground.cgColor]
        layers.frame = bounds
        self.layer.addSublayer(layers)
        
    }
    
    func applyconstraint() {
        
        let imageConstraint = [colletionview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                               colletionview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                               colletionview.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                               colletionview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        
        ]
        
        let pagecontrollerconstraint = [pageController.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                        pageController.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                        pageController.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
                 
                 ]
        
        NSLayoutConstraint.activate(imageConstraint)
        NSLayoutConstraint.activate(pagecontrollerconstraint)
    }
    
    

}

extension homeHeaderView : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCollectionViewCell", for: indexPath) as! headerCollectionViewCell
        
        let stringurl = movieList?[indexPath.row].poster_path ?? ""
        
        if let url = URL(string: "https://image.tmdb.org/t/p/w500\(stringurl)") {
            cell.images.sd_setImage(with: url, placeholderImage: UIImage(named: "photoplaceholder"))
        }
        return cell
        
    }
    
}
