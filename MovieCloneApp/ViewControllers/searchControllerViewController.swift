//
//  searchControllerViewController.swift
//  MovieCloneApp
//
//  Created by Test on 11/05/25.
//

import UIKit

class searchControllerViewController: UIViewController {
    
    var movieData : [Movie]?
    
    
    var collectionview : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectview.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCollectionViewCell")
        return collectview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        collectionview.delegate = self
        view.addSubview(collectionview)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionview.frame = view.bounds
      if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
          layout.itemSize = CGSize(width: self.view.bounds.width/3 - 10, height: 200)
        }
    }
    

   
}
extension searchControllerViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.databinding(imageurl: self.movieData?[indexPath.row].poster_path ?? "")
        return cell
    }
}
