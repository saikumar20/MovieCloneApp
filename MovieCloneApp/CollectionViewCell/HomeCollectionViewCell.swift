import UIKit
import SDWebImage

// MARK: - Movie Collection View Cell
class MovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "MovieCollectionViewCell"
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        posterImageView.sd_cancelCurrentImageLoad()
    }
    
    // MARK: - Configuration
    func configure(with posterPath: String?) {
        guard let posterPath = posterPath,
              let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") else {
            posterImageView.image = UIImage(systemName: "photo")
            return
        }
        
        posterImageView.sd_setImage(
            with: url,
            placeholderImage: UIImage(named: "photoplaceholder"),
            options: [.continueInBackground, .retryFailed]
        )
    }
}
