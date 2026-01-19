import UIKit

class MoviePosterCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "MoviePosterCell"
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        layer.locations = [0.5, 1.0]
        return layer
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
        posterImageView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
        gradientLayer.frame = posterImageView.bounds
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
            posterImageView.image = nil
            return
        }
        
        posterImageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [.continueInBackground, .retryFailed]
        )
    }
}
