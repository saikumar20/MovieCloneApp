//
//  HomeViewController.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import UIKit

//enum Sections : Int {
//    
//    case trendingMovies = 0
//    case trendingTv = 1
//    case popularTv = 2
//    case TopratedTv = 3
//    case upcomingMovies = 4
//    
//}

enum Sections  {
    
    case trendingMovies(data : MovieResponse)
    case trendingTv(data : MovieResponse)
    case popularTv( data : MovieResponse)
    case TopratedTv( data : MovieResponse)
    case upcomingMovies( data : MovieResponse)
    var title : String {
        switch self {
        case .trendingMovies :
            return "Trending Movies"
        case .trendingTv:
            return "Trending Tv"
        case .popularTv:
            return "Popular Tv"
        case .TopratedTv :
            return "Top Rated Tv"
        case .upcomingMovies:
            return "Upcoming Movies"
        }
    }
    var url : String {
        
        switch self {
            
        case .trendingMovies :
            return "\(Constant.movieBaseUrl)\(Constant.trendingMovies)\(Constant.movieApiKey)"
        case .trendingTv:
            return "\(Constant.movieBaseUrl)\(Constant.trendingTv)\(Constant.movieApiKey)"
        case .popularTv:
            return "\(Constant.movieBaseUrl)\(Constant.popular)\(Constant.movieApiKey)\(Constant.mulit)"
        case .TopratedTv :
            return "\(Constant.movieBaseUrl)\(Constant.topRatedTv)\(Constant.movieApiKey)\(Constant.mulit)"
        case .upcomingMovies:
            return "\(Constant.movieBaseUrl)\(Constant.upcomingMovies)\(Constant.movieApiKey)\(Constant.mulit)"
            
        }
    }
}

enum Endpoint {
    
    case trendingMovies
    case trendingTv
    case popularTv
    case TopratedTv
    case upcomingMovies
    
    var url : String {
        switch self {
        case .trendingMovies :
            return "\(Constant.movieBaseUrl)\(Constant.trendingMovies)\(Constant.movieApiKey)"
        case .trendingTv:
            return "\(Constant.movieBaseUrl)\(Constant.trendingTv)\(Constant.movieApiKey)"
        case .popularTv:
            return "\(Constant.movieBaseUrl)\(Constant.popular)\(Constant.movieApiKey)\(Constant.mulit)"
        case .TopratedTv :
            return "\(Constant.movieBaseUrl)\(Constant.topRatedTv)\(Constant.movieApiKey)\(Constant.mulit)"
        case .upcomingMovies:
            return "\(Constant.movieBaseUrl)\(Constant.upcomingMovies)\(Constant.movieApiKey)\(Constant.mulit)"
            
        }
    }
    
}

class HomeViewController: UIViewController {
    
    var movieList : [Movie]?
    var headerView : movieHeader?
    var sectionsList :  [String] = ["Trending Movies","Trending Tv","Popular Tv","Top Rated Tv","Upcoming Movies"]
    var sectionData = [Sections]()
   
    let homeTableView : UITableView = {
        let tableview = UITableView(frame: .zero, style: .grouped)
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.separatorStyle = .none
        tableview.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        tableview.register(headerTableViewCell.self, forCellReuseIdentifier: "headerTableViewCell")
        return tableview
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeTableView)
        homeTableView.delegate = self
        homeTableView.dataSource = self
        headerView = movieHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
        homeTableView.tableHeaderView = headerView
        setupNavigationBar()
        scrollData()
        fetchData()
    }
    
    func fetchData() {
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        

            serviceHandler.shared.movieListApiCall(url: Endpoint.trendingMovies.url) { [weak self] (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    group.leave()
                    self?.sectionData.append(.trendingMovies(data: results))
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
        serviceHandler.shared.movieListApiCall(url: Endpoint.trendingTv.url) { [weak self] (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                group.leave()
                self?.sectionData.append(.trendingTv(data: results))
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
        
        serviceHandler.shared.movieListApiCall(url: Endpoint.popularTv.url) { [weak self] (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                group.leave()
                self?.sectionData.append(.popularTv(data: results))
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
        serviceHandler.shared.movieListApiCall(url: Endpoint.TopratedTv.url) { [weak self] (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                group.leave()
                self?.sectionData.append(.TopratedTv(data: results))
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
        serviceHandler.shared.movieListApiCall(url: Endpoint.upcomingMovies.url) { [weak self] (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                group.leave()
                self?.sectionData.append(.upcomingMovies(data: results))
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
        
        group.notify(queue: .main) {
            self.homeTableView.reloadData()
        }
            
  
        
    }
    
    
  
    
    func scrollData() {
        
        
        
        
        let url = "\(Constant.movieBaseUrl)\(Constant.trendingMovies)\(Constant.movieApiKey)"
        
        serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                self.headerView?.movie = results.results
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeTableView.frame =  view.bounds
    }
    
    
    func setupNavigationBar() {
      
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: nil),UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .plain, target: self, action: nil)]
        
        navigationController?.navigationBar.backgroundColor = .clear
        
        navigationController?.navigationBar.tintColor = .white
        
        
    }
   
    

    

}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        let type = sectionData[indexPath.section]
        
        switch type {
        case .trendingMovies(data: let data) :
            DispatchQueue.main.async {
                cell.databinding(data.results)
                cell.delegate = self
            }
           
        case .trendingTv(data: let data) :
            DispatchQueue.main.async {
                cell.databinding(data.results)
                cell.delegate = self
            }
           
        case .popularTv(data: let data) :
            DispatchQueue.main.async {
                cell.databinding(data.results)
                cell.delegate = self
            }
           
        case .TopratedTv(data: let data) :
            DispatchQueue.main.async {
                cell.databinding(data.results)
                cell.delegate = self
            }
           
        case .upcomingMovies(data: let data) :
            DispatchQueue.main.async {
                cell.databinding(data.results)
                cell.delegate = self
            }
           
        }
        return cell
        
     
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let headerlable = UILabel()
        headerlable.translatesAutoresizingMaskIntoConstraints = false
        headerlable.text = sectionData[section].title
        headerlable.font = .preferredFont(forTextStyle: .body)
        headerlable.textColor = .white
        headerView.addSubview(headerlable)
        
        NSLayoutConstraint.activate([headerlable.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),headerlable.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -5),headerlable.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),headerlable.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
}
extension HomeViewController : previewNavigation {
    func selectedMovie(_ selectedmovie: Movie, _ data: VideoElement?) {
        DispatchQueue.main.async {
            let vc = previewViewController()
            if let videodata = data {
                vc.databinding(selectedmovie, youtubeVideoData: videodata)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}
