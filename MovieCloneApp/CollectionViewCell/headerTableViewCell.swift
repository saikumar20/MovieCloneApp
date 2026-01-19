//
//  headerTableViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 08/05/25.
//

//import UIKit
//
//class headerTableViewCell: UITableViewCell {
//    
//    var movie : [Movie]? {
//        didSet {
//            DispatchQueue.main.async {
//                self.maincollectionview.reloadData()
//            }
//        }
//    }
//    
//    var maincollectionview : UICollectionView = {
//        let collectionlayout = UICollectionViewFlowLayout()
//        collectionlayout.scrollDirection = .horizontal
//        collectionlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionlayout.minimumLineSpacing = 0
//        collectionlayout.minimumInteritemSpacing  = 0
//        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: collectionlayout)
//        collectionview.translatesAutoresizingMaskIntoConstraints = false
//        collectionview.register(scrollCollectionViewCell.self, forCellWithReuseIdentifier: "scrollCollectionViewCell")
//        return collectionview
//    }()
//    
//    var pagecontroller : UIPageControl = {
//       let controller = UIPageControl()
//        controller.currentPage = 0
//        controller.translatesAutoresizingMaskIntoConstraints = false
//        return controller
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//       
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//       
//    }
//
//}
//extension headerTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return movie?.count ?? 0
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scrollCollectionViewCell", for: indexPath) as! scrollCollectionViewCell
//        cell.databinding(movie?[indexPath.row].poster_path ?? "")
//        return cell
//    }
//    
//}
