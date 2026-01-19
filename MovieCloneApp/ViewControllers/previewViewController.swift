//
//  PreviewViewController.swift
//  MovieCloneApp
//
//  Created by Test on 11/05/25.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController {
    
    // MARK: - Properties
    private var movie: Movie?
    private var videoElement: VideoElement?
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .systemBackground
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let web = WKWebView(frame: .zero, configuration: configuration)
        web.translatesAutoresizingMaskIntoConstraints = false
        web.backgroundColor = .black
        web.isOpaque = false
        web.scrollView.isScrollEnabled = false
        web.scrollView.backgroundColor = .black
        web.navigationDelegate = self
        return web
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var downloadButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Download"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.image = UIImage(systemName: "arrow.down.circle.fill")
        config.imagePadding = 8
        config.imagePlacement = .leading
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Share"
        config.baseBackgroundColor = .systemGray
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.imagePadding = 8
        config.imagePlacement = .leading
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [downloadButton, shareButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
        webViewContainer.addSubview(loadingIndicator)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(buttonStackView)
        
        applyConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // WebView Container
            webViewContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            webViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            webViewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            webViewContainer.heightAnchor.constraint(equalToConstant: 250),
            
            // WebView
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: webViewContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: webViewContainer.centerYAnchor),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Release Date Label
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Overview Label
            overviewLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Button Stack
            buttonStackView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with movie: Movie, video: VideoElement?) {
        self.movie = movie
        self.videoElement = video
        
     
        updateUI()
        
        
        if let video = video {
            loadYouTubeVideo(video)
        } else {
            showNoVideoPlaceholder()
        }
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        guard let movie = movie else { return }
        
        // Set title
        titleLabel.text = movie.title ?? movie.name ?? movie.original_name ?? movie.original_title
        
        // Set release date
        if let releaseDate = movie.release_date, !releaseDate.isEmpty {
            releaseDateLabel.text = "Release Date: \(formatReleaseDate(releaseDate))"
        } else {
            releaseDateLabel.text = "Release Date: Not Available"
        }
        
        // Set overview
        overviewLabel.text = movie.overview ?? "No description available."
    }
    
    private func formatReleaseDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func loadYouTubeVideo(_ video: VideoElement) {
        guard let videoId = video.id?.videoId else {
            showNoVideoPlaceholder()
            return
        }
        print("video id is:",videoId)
        loadingIndicator.startAnimating()
        
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                * { margin: 0; padding: 0; }
                body { background-color: #000; }
                .video-container {
                    position: relative;
                    width: 100%;
                    padding-bottom: 56.25%;
                    height: 0;
                }
                .video-container iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe
                    src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    private func showNoVideoPlaceholder() {
        let placeholderHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                * { margin: 0; padding: 0; }
                body {
                    background-color: #1a1a1a;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                }
                .placeholder {
                    text-align: center;
                    color: #888;
                }
                .icon {
                    font-size: 48px;
                    margin-bottom: 16px;
                }
            </style>
        </head>
        <body>
            <div class="placeholder">
                <div class="icon">🎬</div>
                <p>No preview available</p>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(placeholderHTML, baseURL: nil)
    }
    
    // MARK: - Actions
    @objc private func downloadButtonTapped() {
        guard let movie = movie else { return }
        
        downloadButton.configuration?.showsActivityIndicator = true
        downloadButton.isEnabled = false
        
        DownloadedData.shared.saveData(movie) { [weak self] result in
            DispatchQueue.main.async {
                self?.downloadButton.configuration?.showsActivityIndicator = false
                self?.downloadButton.isEnabled = true
                
                switch result {
                case .success:
                    self?.showSuccessAlert(message: "Movie downloaded successfully!")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("downloaded"),
                        object: nil,
                        userInfo: ["MovieDownloaded": true]
                    )
                    
                case .failure(let error):
                    self?.showErrorAlert(message: "Download failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func shareButtonTapped() {
        guard let movie = movie else { return }
        
        let movieName = movie.title ?? movie.name ?? "Movie"
        let shareText = "Check out \(movieName)!"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension PreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("WebView failed to load: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("WebView provisional load failed: \(error.localizedDescription)")
    }
}

// MARK: - Compatibility
// Legacy method for backward compatibility
extension PreviewViewController {
    func databinding(_ data: Movie, youtubeVideoData: VideoElement) {
        configure(with: data, video: youtubeVideoData)
    }
}
