//
//  DownloadViewController.swift
//  MovieCloneApp
//
//  Created by Test on 14/05/25.
//

import UIKit

class DownloadViewController: UIViewController {
    
    
    
    var maintableview : UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.separatorStyle = .none
        tableview.register(upcomingTableViewCell.self, forCellReuseIdentifier: "upcomingTableViewCell")
        return tableview
        
    }()
    
    var DownloadedMovies : [MovieDownloadData]? {
        didSet {
            self.maintableview.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Download"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        fetchupdateddata()
        
        view.addSubview(maintableview)
        maintableview.delegate = self
        maintableview.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(fetchupdateddata), name: NSNotification.Name("downloaded"), object: nil)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maintableview.frame = view.bounds
    }
    
    
    @objc func fetchupdateddata() {
        DownloadedData.shared.getData { result in
            switch result {
            case .success(let data) :
                self.DownloadedMovies = data
                break
            case .failure(let error) :
                print(error)
                break
            }
        }
    }
    

}
extension DownloadViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DownloadedMovies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete :
            if let data = self.DownloadedMovies?[indexPath.row] {
                DownloadedData.shared.deleteData(data) { response in
                    switch response {
                    case .success(_) :
                        self.DownloadedMovies?.remove(at: indexPath.row)
                        self.maintableview.deselectRow(at: indexPath, animated: true)
                        break
                    case .failure(_) :
                        break
                    }
                }
            }
            break
        default :
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingTableViewCell", for: indexPath) as! upcomingTableViewCell
        
        if let data = self.DownloadedMovies?[indexPath.row] {
            cell.databindingForDownload(data)
        }
        return cell
    }
    
    
    
}
