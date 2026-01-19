

import UIKit
import SDWebImage

class UpcomingTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "UpcomingTableViewCell"
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false // Cell selection handles tap
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(playButton)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(releaseDateLabel)
        stackView.addArrangedSubview(overviewLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Poster Image
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            posterImageView.widthAnchor.constraint(equalToConstant: 90),
            
            // Play Button
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Stack View
            stackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        posterImageView.sd_cancelCurrentImageLoad()
        titleLabel.text = nil
        releaseDateLabel.text = nil
        overviewLabel.text = nil
    }
    
    // MARK: - Configuration
    func configure(with movie: Movie) {
        // Set title
        titleLabel.text = movie.original_title ?? movie.title ?? movie.original_name ?? movie.name ?? "Unknown Title"
        
        // Set release date
        if let releaseDate = movie.release_date, !releaseDate.isEmpty {
            releaseDateLabel.text = formatReleaseDate(releaseDate)
            releaseDateLabel.isHidden = false
        } else {
            releaseDateLabel.isHidden = true
        }
        
        // Set overview
        if let overview = movie.overview, !overview.isEmpty {
            overviewLabel.text = overview
            overviewLabel.isHidden = false
        } else {
            overviewLabel.isHidden = true
        }
        
        // Load poster image
        loadPosterImage(movie.poster_path)
    }
    
    func configure(with downloadedMovie: MovieDownloadData) {
        // Set title
        titleLabel.text = downloadedMovie.original_title ?? downloadedMovie.title ?? downloadedMovie.original_name ?? downloadedMovie.name ?? "Unknown Title"
        
        // Set release date
        if let releaseDate = downloadedMovie.release_date, !releaseDate.isEmpty {
            releaseDateLabel.text = formatReleaseDate(releaseDate)
            releaseDateLabel.isHidden = false
        } else {
            releaseDateLabel.isHidden = true
        }
        
        // Set overview
        if let overview = downloadedMovie.overview, !overview.isEmpty {
            overviewLabel.text = overview
            overviewLabel.isHidden = false
        } else {
            overviewLabel.isHidden = true
        }
        
        // Load poster image
        loadPosterImage(downloadedMovie.poster_path)
    }
    
    // MARK: - Helper Methods
    private func loadPosterImage(_ posterPath: String?) {
        guard let posterPath = posterPath,
              let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") else {
            posterImageView.image = UIImage(systemName: "photo")
            return
        }
        
        posterImageView.sd_setImage(
            with: url,
            placeholderImage: UIImage(named: "photoplaceholder"),
            options: [.continueInBackground, .retryFailed]
        ) { [weak self] image, error, _, _ in
            if error != nil {
                self?.posterImageView.image = UIImage(systemName: "photo")
            }
        }
    }
    
    private func formatReleaseDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Animation
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.alpha = highlighted ? 0.7 : 1.0
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
