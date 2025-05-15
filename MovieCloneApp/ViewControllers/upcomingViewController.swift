//
//  upcomingViewController.swift
//  MovieCloneApp
//
//  Created by Test on 10/05/25.
//

import UIKit

class upcomingViewController: UIViewController {
    
    
    var movieData : [Movie]? {
        didSet {
            DispatchQueue.main.async {
                self.upcomingTableview.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(upcomingTableview)
        upcomingTableview.delegate = self
        upcomingTableview.dataSource = self
        fetchupcomingMoviesData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableview.frame = view.bounds
    }
    
    func fetchupcomingMoviesData() {
        
        let url = "\(Constant.movieBaseUrl)\(Constant.upcomingMovies)\(Constant.movieApiKey)\(Constant.mulit)"
        
        serviceHandler.shared.movieListApiCall(url: url) { (result : Result<MovieResponse,Error>) in
            switch result {
            case .success(let resutl) :
                self.movieData = resutl.results
                break
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    var upcomingTableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.separatorStyle = .none
        tableview.register(upcomingTableViewCell.self, forCellReuseIdentifier: "upcomingTableViewCell")
        return tableview
    }()


}

extension upcomingViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  movieData?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "upcomingTableViewCell", for: indexPath) as! upcomingTableViewCell
        
        DispatchQueue.main.async {
            if let data = self.movieData?[indexPath.row] {
                cell.databinding(data)
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
