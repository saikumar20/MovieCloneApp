//
//  searchViewController.swift
//  MovieCloneApp
//
//  Created by Test on 10/05/25.
//

import UIKit

class searchViewController: UIViewController, UISearchResultsUpdating {
   
    
    
    var movieData : [Movie]?
    
    let searchElement : UISearchController = {
        let element = UISearchController(searchResultsController: searchControllerViewController())
        element.searchBar.placeholder = "Search Movies..."
        element.searchBar.tintColor = .white
        element.searchBar.searchBarStyle = .minimal
        return element
    }()

    let tableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.separatorStyle = .none
        tableview.register(upcomingTableViewCell.self, forCellReuseIdentifier: "upcomingTableViewCell")
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableview)
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.navigationItem.searchController = self.searchElement
        tableview.delegate = self
        tableview.dataSource = self
        searchElement.searchResultsUpdater = self
        searchElement.obscuresBackgroundDuringPresentation = true
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    
    func fetchData() {
        
        
        let url = "\(Constant.movieBaseUrl)\(Constant.topRatedTv)\(Constant.movieApiKey)\(Constant.mulit)"
        
        serviceHandler.shared.movieListApiCall(url: url) { (response : Result<MovieResponse,Error>) in
            switch response {
            case .success(let results) :
                DispatchQueue.main.async {
                    self.movieData = results.results
                    self.tableview.reloadData()
                }
            case .failure(let error) :
                print(error.localizedDescription)
            
            }
        }
        
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        
        if let searchTxt = text , !searchTxt.trimmingCharacters(in: .whitespaces).isEmpty,searchTxt.trimmingCharacters(in: .whitespaces).count > 3 {
            
            guard let resultcontroller = searchController.searchResultsController as? searchControllerViewController else {return}
            
            
            guard let queryVal =  searchTxt.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)else {return}
            
            let url = "\(Constant.movieBaseUrl)\(Constant.search)\(Constant.movieApiKey)\(Constant.query)\(queryVal)"
            
            
            serviceHandler.shared.movieListApiCall(url: url) { (result : Result<MovieResponse,Error>) in
                
                switch result {
                case .success(let response) :
                    resultcontroller.movieData = response.results
                    DispatchQueue.main.async {
                        resultcontroller.collectionview.reloadData()
                    }
                    
                    break
                case .failure(let error) :
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
}
extension searchViewController : UITableViewDelegate , UITableViewDataSource {
    
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
