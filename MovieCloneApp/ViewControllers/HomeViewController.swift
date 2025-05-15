//
//  HomeViewController.swift
//  MovieCloneApp
//
//  Created by Test on 06/05/25.
//

import UIKit

enum Sections : Int {
    
    case trendingMovies = 0
    case trendingTv = 1
    case popularTv = 2
    case TopratedTv = 3
    case upcomingMovies = 4
    
}


class HomeViewController: UIViewController {
    
    var movieList : [Movie]?
    var headerView : movieHeader?
    var sectionsList :  [String] = ["Trending Movies","Trending Tv","Popular Tv","Top Rated Tv","Upcoming Movies"]
   
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
        switch indexPath.section {
            
        case Sections.trendingMovies.rawValue :
            let url = "\(Constant.movieBaseUrl)\(Constant.trendingMovies)\(Constant.movieApiKey)"
            
            serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    cell.databinding(results.results)
                    cell.delegate = self
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
            
            
        case Sections.trendingTv.rawValue :
            let url = "\(Constant.movieBaseUrl)\(Constant.trendingTv)\(Constant.movieApiKey)"
            
            serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    cell.databinding(results.results)
                    cell.delegate = self
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
            
        case Sections.popularTv.rawValue :
            let url = "\(Constant.movieBaseUrl)\(Constant.popular)\(Constant.movieApiKey)\(Constant.mulit)"
            
            serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    cell.databinding(results.results)
                    cell.delegate = self
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
        case Sections.TopratedTv.rawValue :
            let url = "\(Constant.movieBaseUrl)\(Constant.topRatedTv)\(Constant.movieApiKey)\(Constant.mulit)"
            
            serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    cell.databinding(results.results)
                    cell.delegate = self
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
            
        case Sections.upcomingMovies.rawValue :
            let url = "\(Constant.movieBaseUrl)\(Constant.upcomingMovies)\(Constant.movieApiKey)\(Constant.mulit)"
            
            serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
                switch response {
                case .success(let results) :
                    cell.databinding(results.results)
                    cell.delegate = self
                case .failure(let error) :
                    print(error.localizedDescription)
                
                }
            }
            
        default :
            break
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let headerlable = UILabel()
        headerlable.translatesAutoresizingMaskIntoConstraints = false
        headerlable.text = sectionsList[section]
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
