
import UIKit

class UpcomingViewController: UIViewController {
    
    // MARK: - Properties
    private var movies: [Movie] = [] {
        didSet {
            upcomingTableView.reloadData()
        }
    }
    
    private var isLoading = false
    
    // MARK: - UI Components
    private lazy var upcomingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No upcoming movies available"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fetchUpcomingMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(upcomingTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
    }
    

    private func fetchUpcomingMovies() {
        guard !isLoading else { return }
        
        isLoading = true
        showLoadingState()
        
        let url = "\(Constant.movieBaseUrl)\(Constant.upcomingMovies)\(Constant.movieApiKey)\(Constant.mulit)"
        
        serviceHandler.shared.movieListApiCall(url: url) { [weak self] (result: Result<MovieResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.hideLoadingState()
                
                switch result {
                case .success(let response):
                    self.movies = response.results ?? []
                    self.updateEmptyState()
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
 
    @objc private func handleRefresh() {
        fetchUpcomingMovies()
    }
    

    private func showLoadingState() {
        if movies.isEmpty {
            loadingIndicator.startAnimating()
            upcomingTableView.isHidden = true
        }
    }
    
    private func hideLoadingState() {
        loadingIndicator.stopAnimating()
        upcomingTableView.isHidden = false
        refreshControl.endRefreshing()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !movies.isEmpty
        upcomingTableView.isHidden = movies.isEmpty
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load upcoming movies. Please try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchUpcomingMovies()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Movie Selection
    private func handleMovieSelection(at indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        
        // Fetch YouTube video for preview
        let movieName = movie.original_title ?? movie.title ?? movie.original_name ?? movie.name ?? ""
        guard let encodedQuery = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
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
extension UpcomingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UpcomingTableViewCell.identifier,
            for: indexPath
        ) as? UpcomingTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UpcomingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleMovieSelection(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = movies[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let downloadAction = UIAction(
                title: "Download",
                image: UIImage(systemName: "arrow.down.circle")
            ) { _ in
                self.downloadMovie(movie)
            }
            
            let shareAction = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                self.shareMovie(movie)
            }
            
            return UIMenu(children: [downloadAction, shareAction])
        }
        
        return configuration
    }
    
  
    private func downloadMovie(_ movie: Movie) {
        DownloadedData.shared.saveData(movie) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showSuccessMessage("Movie downloaded successfully")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("downloaded"),
                        object: nil,
                        userInfo: ["MovieDownloaded": true]
                    )
                    
                case .failure(let error):
                    self.showErrorMessage("Download failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func shareMovie(_ movie: Movie) {
        let movieName = movie.title ?? movie.name ?? "Movie"
        let shareText = "Check out \(movieName) on our app!"
        
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
