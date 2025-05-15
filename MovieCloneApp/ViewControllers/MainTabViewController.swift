//
//  MainTabViewController.swift
//  MovieCloneApp
//
//  Created by Test on 07/05/25.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: upcomingViewController())
        let vc3 = UINavigationController(rootViewController: searchViewController())
        let vc4 = UINavigationController(rootViewController: DownloadViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "play.circle")
        vc3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        vc4.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        vc1.tabBarItem.title = "Home"
        vc2.tabBarItem.title = "Upcoming"
        vc3.tabBarItem.title = "Search"
        vc4.tabBarItem.title = "Download"
        self.tabBar.tintColor = .white
        
        setViewControllers([vc1,vc2,vc3,vc4], animated: true)

    }
    
    
 
    

    

}
