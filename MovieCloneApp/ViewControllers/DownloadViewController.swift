//
//  DownloadViewController.swift
//  MovieCloneApp
//
//  Created by Test on 14/05/25.
//

import UIKit

class DownloadViewController: UIViewController {
    
    // MARK: - Properties
    private var downloadedMovies: [MovieDownloadData] = [] {
        didSet {
            updateEmptyState()
        }
    }
    
    private var isLoading = false
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.refreshControl = refreshControl
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
        imageView.image = UIImage(systemName: "arrow.down.circle")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Downloads Yet"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Movies and TV shows you download will appear here"
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
        setupNotifications()
        fetchDownloadedMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDownloadedMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitleLabel)
        
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
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            // Empty State Subtitle
            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 16),
            emptyStateSubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -16),
            emptyStateSubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        updateNavigationBar()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadNotification),
            name: NSNotification.Name("downloaded"),
            object: nil
        )
    }
    
    // MARK: - Data Fetching
    private func fetchDownloadedMovies() {
        guard !isLoading else { return }
        
        isLoading = true
        showLoadingState()
        
        DownloadedData.shared.getData { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.hideLoadingState()
                
                switch result {
                case .success(let movies):
                    self.downloadedMovies = movies
                    self.tableView.reloadData()
                    self.updateNavigationBar()
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleRefresh() {
        fetchDownloadedMovies()
    }
    
    @objc private func handleDownloadNotification(_ notification: Notification) {
        fetchDownloadedMovies()
    }
    
    @objc private func clearAllTapped() {
        let alert = UIAlertController(
            title: "Clear All Downloads",
            message: "Are you sure you want to delete all downloaded movies? This action cannot be undone.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.deleteAllDownloads()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    private func deleteAllDownloads() {
        let moviesToDelete = downloadedMovies
        
        // Optimistically update UI
        downloadedMovies = []
        tableView.reloadData()
        updateNavigationBar()
        
        // Perform actual deletion
        var deletionErrors: [Error] = []
        let group = DispatchGroup()
        
        for movie in moviesToDelete {
            group.enter()
            DownloadedData.shared.deleteData(movie) { result in
                if case .failure(let error) = result {
                    deletionErrors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            if deletionErrors.isEmpty {
                self?.showSuccessMessage("All downloads cleared")
            } else {
                self?.showErrorMessage("Failed to clear some downloads")
                self?.fetchDownloadedMovies()
            }
        }
    }
    
    private func deleteMovie(at indexPath: IndexPath) {
        guard indexPath.row < downloadedMovies.count else { return }
        let movie = downloadedMovies[indexPath.row]
        
        // Remove from data source immediately
        downloadedMovies.remove(at: indexPath.row)
        
        // Animate the deletion
        tableView.deleteRows(at: [indexPath], with: .automatic)
        updateNavigationBar()
        
        // Perform the actual deletion
        DownloadedData.shared.deleteData(movie) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .failure(let error) = result {
                    // If deletion failed, revert by fetching fresh data
                    self.handleError(error)
                    self.fetchDownloadedMovies()
                }
            }
        }
    }
    
    private func updateNavigationBar() {
        if downloadedMovies.isEmpty {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Clear All",
                style: .plain,
                target: self,
                action: #selector(clearAllTapped)
            )
        }
    }
    
    // MARK: - UI State Management
    private func showLoadingState() {
        if downloadedMovies.isEmpty {
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
        let isEmpty = downloadedMovies.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func handleError(_ error: Error) {
        showErrorMessage("An error occurred: \(error.localizedDescription)")
    }
    
    // MARK: - Movie Selection
    private func handleMovieSelection(at indexPath: IndexPath) {
        guard indexPath.row < downloadedMovies.count else { return }
        
        let downloadedMovie = downloadedMovies[indexPath.row]
        
        // Convert MovieDownloadData to Movie
        let movie = Movie(
            id: Int(downloadedMovie.id),
            backdrop_path: downloadedMovie.backdrop_path,
            original_title: downloadedMovie.original_title,
            overview: downloadedMovie.overview,
            popularity: downloadedMovie.popularity,
            poster_path: downloadedMovie.poster_path,
            release_date: downloadedMovie.release_date,
            title: downloadedMovie.title,
            name: downloadedMovie.name,
            original_name: downloadedMovie.original_name
        )
        
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
    
    // MARK: - Helper Methods
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DownloadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UpcomingTableViewCell.identifier,
            for: indexPath
        ) as? UpcomingTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = downloadedMovies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteMovie(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension DownloadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleMovieSelection(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteMovie(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < downloadedMovies.count else { return nil }
        
        let movie = downloadedMovies[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let playAction = UIAction(
                title: "Play",
                image: UIImage(systemName: "play.circle")
            ) { [weak self] _ in
                self?.handleMovieSelection(at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteMovie(at: indexPath)
            }
            
            let shareAction = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                self?.shareMovie(movie)
            }
            
            return UIMenu(children: [playAction, shareAction, deleteAction])
        }
    }
    
    // MARK: - Context Menu Actions
    private func shareMovie(_ movie: MovieDownloadData) {
        let movieName = movie.title ?? movie.name ?? "Movie"
        let shareText = "Check out \(movieName)!"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
}
