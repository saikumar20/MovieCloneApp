//
//  movieHeader.swift
//  MovieCloneApp
//
//  Created by Test on 09/05/25.
//

import UIKit

class movieHeader: UIView {
    
    
    var imageIndex : Int = 0

    var movie : [Movie]? {
        didSet {
            DispatchQueue.main.async {
                self.maincollectionview.reloadData()
                self.pagecontroller.numberOfPages = self.movie?.count ?? 0
            }
        }
    }
    
    var maincollectionview : UICollectionView = {
        let collectionlayout = UICollectionViewFlowLayout()
        collectionlayout.scrollDirection = .horizontal
        collectionlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionlayout.minimumLineSpacing = 0
        collectionlayout.minimumInteritemSpacing  = 0
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: collectionlayout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.register(scrollCollectionViewCell.self, forCellWithReuseIdentifier: "scrollCollectionViewCell")
        return collectionview
    }()
    
    var pagecontroller : UIPageControl = {
       let controller = UIPageControl()
        controller.currentPage = 0
        controller.translatesAutoresizingMaskIntoConstraints = false
//        controller.addTarget(self, action: #selector(pagecontrollerChanged(_ :)), for: .valueChanged)
        return controller
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(maincollectionview)
        addSubview(pagecontroller)
        applyconstraint()
        maincollectionview.delegate = self
        maincollectionview.dataSource = self
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(autoscroller), userInfo: nil, repeats: true)
    }
    
    
//    @objc func pagecontrollerChanged(_ sender : UIPageControl) {
//        
//        let selectedIndex = IndexPath(item: sender.currentPage, section: 0)
//        self.maincollectionview.scrollToItem(at: selectedIndex, at: .centeredHorizontally, animated: true)
//        
//    }
    
    @objc func autoscroller() {
        
        if imageIndex < (self.movie?.count ?? 0) - 1 {
            imageIndex += 1
            self.pagecontroller.currentPage = self.imageIndex
            maincollectionview.scrollToItem(at: IndexPath(row: imageIndex, section: 0), at: .right, animated: true)
        }else {
            imageIndex = 0
            self.pagecontroller.currentPage = self.imageIndex
            
            if movie?.count ?? 0 > 0 {
                maincollectionview.scrollToItem(at: IndexPath(row: imageIndex, section: 0), at: .right, animated: true)

            }
        }
            
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layouts = self.maincollectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layouts.itemSize = CGSize(width: bounds.width, height: 400)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyconstraint() {
       NSLayoutConstraint.activate([maincollectionview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),maincollectionview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),maincollectionview.topAnchor.constraint(equalTo: topAnchor, constant: 0),maincollectionview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)])
        
        
        NSLayoutConstraint.activate([pagecontroller.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),pagecontroller.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),pagecontroller.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)])
        
    }
    
}


extension movieHeader : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movie?.count ?? 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index : CGFloat = (maincollectionview.contentOffset.x / maincollectionview.frame.width)
        self.imageIndex = Int(index)
        self.pagecontroller.currentPage = Int(index)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scrollCollectionViewCell", for: indexPath) as! scrollCollectionViewCell
        cell.databinding(movie?[indexPath.row].poster_path ?? "")
        return cell
    }
    
   
    
}
