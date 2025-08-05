//
//  HomeTableViewCell.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import UIKit
import SDWebImage
import CoreData
protocol previewNavigation {
    func selectedMovie(_ selectedmovie :Movie,_ data :VideoElement?)
}

class HomeTableViewCell: UITableViewCell {
    
    var movieData : [Movie]?
    var delegate : previewNavigation?
    
    let colletionview : UICollectionView = {
        let collectionviewlayout = UICollectionViewFlowLayout()
        collectionviewlayout.scrollDirection = .horizontal
//        collectionviewlayout.minimumLineSpacing = 0
//        collectionviewlayout.minimumInteritemSpacing = 0
        collectionviewlayout.itemSize = CGSize(width: 132, height: 200)
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: collectionviewlayout)
        collectionview.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCollectionViewCell")
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        return collectionview
    }()
    
   
   

    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(colletionview)
        contentView.backgroundColor = .yellow
        colletionview.dataSource = self
        colletionview.delegate = self
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colletionview.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    func databinding(_ data : [Movie]?) {
        self.movieData = data
        DispatchQueue.main.async { [weak self] in
            self?.colletionview.reloadData()
        }
    }
    
    func downlaodfunnc(_ data : Movie) {
        DownloadedData.shared.saveData(data) { result in
            switch result  {
            case .success(let success) :
                print(success)
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil, userInfo: ["MovieDownloaded" : true])
                
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    
   

}
extension HomeTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieData?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.databinding(imageurl: self.movieData?[indexPath.row].poster_path)
        return cell
    }
    

    
  
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPaths: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            let download = UIAction(title : "Download") { _ in
                if let data = self?.movieData?[indexPaths.row] {
                    self?.downlaodfunnc(data)
                }
            }
            return UIMenu(options: .displayInline,children: [download])
        })
        return configuration
    }
    
    
   
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = self.movieData?[indexPath.row] {
            
            let value = data.original_title ?? data.title ?? data.original_name ?? data.name
            let query = value?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            let youtubeLink = "\(Constant.youtubeBaseUrl)\(Constant.youtubesearchquery)\(String(describing: query ?? ""))\(Constant.youtubequerykey)\(Constant.youtubeApiKey)"
            
            serviceHandler.shared.movieListApiCall(url: youtubeLink) { (result : Result<YoutubeResponse,Error>) in
                switch result {
                case .success(let response) :
                    self.delegate?.selectedMovie(data,response.items?[0])
                    break
                case .failure(let error) :
                    print(error.localizedDescription)
                }
            }
        } 
    }
    
}
