

import UIKit

class SearchViewController: UIViewController {
    

    private var discoverMovies: [Movie] = [] {
        didSet {
            tableView.reloadData()
            updateEmptyState()
        }
    }
    
    private var isLoading = false
    private var searchWorkItem: DispatchWorkItem?
    
   
    private lazy var searchController: UISearchController = {
        let resultsVC = SearchResultsViewController()
        resultsVC.delegate = self
        
        let controller = UISearchController(searchResultsController: resultsVC)
        controller.searchBar.placeholder = "Search for movies or TV shows"
        controller.searchBar.tintColor = .label
        controller.searchBar.searchBarStyle = .minimal
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = true
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.refreshControl = refreshControl
        table.keyboardDismissMode = .onDrag
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .label
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover popular movies and TV shows"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fetchDiscoverMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Empty State Image
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Data Fetching
    private func fetchDiscoverMovies() {
        guard !isLoading else { return }
        
        isLoading = true
        showLoadingState()
        
        let url = "\(Constant.movieBaseUrl)\(Constant.topRatedTv)\(Constant.movieApiKey)\(Constant.mulit)"
        
        serviceHandler.shared.movieListApiCall(url: url) { [weak self] (result: Result<MovieResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.hideLoadingState()
                
                switch result {
                case .success(let response):
                    self.discoverMovies = response.results ?? []
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func performSearch(with query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let url = "\(Constant.movieBaseUrl)\(Constant.search)\(Constant.movieApiKey)\(Constant.query)\(encodedQuery)"
        
        serviceHandler.shared.movieListApiCall(url: url) { [weak self] (result: Result<MovieResponse, Error>) in
            guard let self = self,
                  let resultsVC = self.searchController.searchResultsController as? SearchResultsViewController else {
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    resultsVC.updateResults(response.results ?? [])
                    
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                    resultsVC.updateResults([])
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleRefresh() {
        fetchDiscoverMovies()
    }
    
    // MARK: - UI State Management
    private func showLoadingState() {
        if discoverMovies.isEmpty {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            emptyStateView.isHidden = true
        }
    }
    
    private func hideLoadingState() {
        loadingIndicator.stopAnimating()
        tableView.isHidden = false
        refreshControl.endRefreshing()
    }
    
    private func updateEmptyState() {
        let isEmpty = discoverMovies.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load movies. Please try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchDiscoverMovies()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Movie Selection
    private func handleMovieSelection(_ movie: Movie) {
        let movieName = movie.original_title ?? movie.title ?? movie.original_name ?? movie.name ?? ""
        
        guard !movieName.isEmpty,
              let encodedQuery = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            showPreview(for: movie, video: nil)
            return
        }
        
        let youtubeURL = "\(Constant.youtubeBaseUrl)\(Constant.youtubesearchquery)\(encodedQuery)\(Constant.youtubequerykey)\(Constant.youtubeApiKey)"
        
        serviceHandler.shared.movieListApiCall(url: youtubeURL) { [weak self] (result: Result<YoutubeResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.showPreview(for: movie, video: response.items?.first)
                case .failure:
                    self?.showPreview(for: movie, video: nil)
                }
            }
        }
    }
    
    private func showPreview(for movie: Movie, video: VideoElement?) {
        let previewVC = PreviewViewController()
        previewVC.configure(with: movie, video: video)
        navigationController?.pushViewController(previewVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoverMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UpcomingTableViewCell.identifier,
            for: indexPath
        ) as? UpcomingTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = discoverMovies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = discoverMovies[indexPath.row]
        handleMovieSelection(movie)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = discoverMovies[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let downloadAction = UIAction(
                title: "Download",
                image: UIImage(systemName: "arrow.down.circle")
            ) { [weak self] _ in
                self?.downloadMovie(movie)
            }
            
            let shareAction = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                self?.shareMovie(movie)
            }
            
            return UIMenu(children: [downloadAction, shareAction])
        }
    }
    
    // MARK: - Context Menu Actions
    private func downloadMovie(_ movie: Movie) {
        DownloadedData.shared.saveData(movie) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showSuccessMessage("Movie downloaded successfully")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("downloaded"),
                        object: nil,
                        userInfo: ["MovieDownloaded": true]
                    )
                    
                case .failure(let error):
                    self?.showErrorMessage("Download failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func shareMovie(_ movie: Movie) {
        let movieName = movie.title ?? movie.name ?? "Movie"
        let shareText = "Check out \(movieName)!"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Cancel previous search
        searchWorkItem?.cancel()
        
        guard let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces),
              !searchText.isEmpty else {
            if let resultsVC = searchController.searchResultsController as? SearchResultsViewController {
                resultsVC.updateResults([])
            }
            return
        }
        
        // Debounce search - wait 0.5 seconds after user stops typing
        let workItem = DispatchWorkItem { [weak self] in
            if searchText.count >= 2 {
                self?.performSearch(with: searchText)
            }
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}

// MARK: - SearchResultsDelegate
extension SearchViewController: SearchResultsDelegate {
    func didSelectSearchResult(_ movie: Movie) {
        searchController.dismiss(animated: false)
        handleMovieSelection(movie)
    }
}
