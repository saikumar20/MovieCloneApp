
import UIKit

enum MovieEndpoint {
    case trendingMovies
    case trendingTV
    case popularTV
    case topRatedTV
    case upcomingMovies
    
    var title: String {
        switch self {
        case .trendingMovies: return "Trending Movies"
        case .trendingTV: return "Trending TV"
        case .popularTV: return "Popular TV"
        case .topRatedTV: return "Top Rated TV"
        case .upcomingMovies: return "Upcoming Movies"
        }
    }
    
    var url: String {
        let baseURL = Constant.movieBaseUrl
        let apiKey = Constant.movieApiKey
        let multi = Constant.mulit
        
        switch self {
        case .trendingMovies:
            return "\(baseURL)\(Constant.trendingMovies)\(apiKey)"
        case .trendingTV:
            return "\(baseURL)\(Constant.trendingTv)\(apiKey)"
        case .popularTV:
            return "\(baseURL)\(Constant.popular)\(apiKey)\(multi)"
        case .topRatedTV:
            return "\(baseURL)\(Constant.topRatedTv)\(apiKey)\(multi)"
        case .upcomingMovies:
            return "\(baseURL)\(Constant.upcomingMovies)\(apiKey)\(multi)"
        }
    }
}

// MARK: - Section Model
struct MovieSection {
    let endpoint: MovieEndpoint
    let movies: [Movie]
    
    var title: String {
        endpoint.title
    }
}

class HomeViewController: UIViewController {
    
  
        private var sections: [MovieSection] = []
        private var headerMovies: [Movie] = []
        private let endpoints: [MovieEndpoint] = [
            .trendingMovies,
            .trendingTV,
            .popularTV,
            .topRatedTV,
            .upcomingMovies
        ]
    
        private lazy var homeTableView: UITableView = {
            let tableView = UITableView(frame: .zero, style: .grouped)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.separatorStyle = .none
            tableView.backgroundColor = .systemBackground
            tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
            return tableView
        }()
    
    private lazy var headerView: MovieHeaderView = {
           let header = MovieHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 400))
           return header
       }()
    
 
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupNavigationBar()
            fetchAllData()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            homeTableView.frame = view.bounds
        }
    
    
   
       private func setupUI() {
           view.backgroundColor = .systemBackground
           view.addSubview(homeTableView)
           homeTableView.tableHeaderView = headerView
           
           NSLayoutConstraint.activate([
               homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
               homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
       }
    
    private func setupNavigationBar() {
           guard let logoImage = UIImage(named: "netflixLogo")?.withRenderingMode(.alwaysOriginal) else {
               return
           }
           
           navigationItem.leftBarButtonItem = UIBarButtonItem(
               image: logoImage,
               style: .plain,
               target: nil,
               action: nil
           )
           
           navigationItem.rightBarButtonItems = [
               UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: nil, action: nil),
               UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .plain, target: nil, action: nil)
           ]
           
           navigationController?.navigationBar.tintColor = .white
           navigationController?.navigationBar.backgroundColor = .clear
       }
    

        private func fetchAllData() {
            let dispatchGroup = DispatchGroup()
            var fetchedSections: [MovieSection] = []
            let sectionsLock = NSLock()
            
           
            dispatchGroup.enter()
            fetchMovies(for: .trendingMovies) { [weak self] result in
                defer { dispatchGroup.leave() }
                if case .success(let response) = result {
                    self?.headerMovies = response.results ?? []
                    DispatchQueue.main.async {
                        self?.headerView.configure(with: response.results ?? [])
                    }
                }
            }
            
        
            for endpoint in endpoints {
                dispatchGroup.enter()
                fetchMovies(for: endpoint) { result in
                    defer { dispatchGroup.leave() }
                    if case .success(let response) = result {
                        let section = MovieSection(endpoint: endpoint, movies: response.results ?? [])
                        sectionsLock.lock()
                        fetchedSections.append(section)
                        sectionsLock.unlock()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
        
                self?.sections = self?.endpoints.compactMap { endpoint in
                    fetchedSections.first { $0.endpoint.title == endpoint.title }
                } ?? []
                self?.homeTableView.reloadData()
            }
        }
    
    private func fetchMovies(for endpoint: MovieEndpoint, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
           serviceHandler.shared.movieListApiCall(url: endpoint.url, completion: completion)
       }
  

}


extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeTableViewCell.identifier,
            for: indexPath
        ) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let section = sections[indexPath.section]
        cell.configure(with: section.movies)
        cell.delegate = self
        
        return cell
    }
}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sections[section].title
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
extension HomeViewController : MovieSelectionDelegate {

    
    func didSelectMovie(_ movie: Movie, with video: VideoElement?) {
            let previewVC = PreviewViewController()
            previewVC.configure(with: movie, video: video)
            navigationController?.pushViewController(previewVC, animated: true)
        }
    
    
}
