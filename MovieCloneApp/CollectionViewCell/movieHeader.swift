//
//  MovieHeaderView.swift
//  MovieCloneApp//

import UIKit

class MovieHeaderView: UIView {
    

    private var movies: [Movie] = []
    private var currentIndex: Int = 0
    private var autoScrollTimer: Timer?
    

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .systemGray
        pc.currentPageIndicatorTintColor = .white
        pc.isUserInteractionEnabled = false
        return pc
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAutoScroll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopAutoScroll()
    }
    

    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = bounds.size
        }
    }
    

    func configure(with movies: [Movie]) {
        self.movies = movies
        pageControl.numberOfPages = movies.count
        collectionView.reloadData()
    }
    

    private func setupAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(autoScroll),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @objc private func autoScroll() {
        guard !movies.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % movies.count
        pageControl.currentPage = currentIndex
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}


extension MovieHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviePosterCell.identifier,
            for: indexPath
        ) as? MoviePosterCell else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.item]
        cell.configure(with: movie.poster_path)
        
        return cell
    }
}


extension MovieHeaderView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let newIndex = Int(scrollView.contentOffset.x / pageWidth)
        
        if newIndex != currentIndex {
            currentIndex = newIndex
            pageControl.currentPage = newIndex
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setupAutoScroll()
    }
}
