//
//  HomeTableViewCell.swift
//  MovieCloneApp
//
//  Refactored by Claude
//

import UIKit
import SDWebImage

// MARK: - Movie Selection Delegate
protocol MovieSelectionDelegate: AnyObject {
    func didSelectMovie(_ movie: Movie, with video: VideoElement?)
}

// MARK: - Home Table View Cell
class HomeTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "HomeTableViewCell"
    
    weak var delegate: MovieSelectionDelegate?
    private var movies: [Movie] = []
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 132, height: 200)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.showsHorizontalScrollIndicator = false
        cv.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        
        return cv
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        selectionStyle = .none
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with movies: [Movie]) {
        self.movies = movies
        collectionView.reloadData()
    }
    
    // MARK: - Download Handling
    private func downloadMovie(_ movie: Movie) {
        DownloadedData.shared.saveData(movie) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("downloaded"),
                        object: nil,
                        userInfo: ["MovieDownloaded": true]
                    )
                }
            case .failure(let error):
                print("Download failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Video Fetching
    private func fetchYouTubeVideo(for movie: Movie, completion: @escaping (VideoElement?) -> Void) {
        let movieName = movie.original_title ?? movie.title ?? movie.original_name ?? movie.name ?? ""
        guard let encodedQuery = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let youtubeURL = "\(Constant.youtubeBaseUrl)\(Constant.youtubesearchquery)\(encodedQuery)\(Constant.youtubequerykey)\(Constant.youtubeApiKey)"
        
        serviceHandler.shared.movieListApiCall(url: youtubeURL) { (result: Result<YoutubeResponse, Error>) in
            switch result {
            case .success(let response):
                completion(response.items?.first)
            case .failure(let error):
                print("YouTube fetch failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.item]
        cell.configure(with: movie.poster_path)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        
        fetchYouTubeVideo(for: movie) { [weak self] video in
            DispatchQueue.main.async {
                self?.delegate?.didSelectMovie(movie, with: video)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = movies[indexPath.item]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(
                title: "Download",
                image: UIImage(systemName: "arrow.down.circle")
            ) { _ in
                self?.downloadMovie(movie)
            }
            
            return UIMenu(options: .displayInline, children: [downloadAction])
        }
        
        return configuration
    }
}
