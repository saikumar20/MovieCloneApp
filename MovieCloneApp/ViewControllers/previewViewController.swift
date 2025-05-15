//
//  previewViewController.swift
//  MovieCloneApp
//
//  Created by Test on 11/05/25.
//

import UIKit
import WebKit

class previewViewController: UIViewController, WKNavigationDelegate {
    
    let web : WKWebView = {
       let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webvideo = WKWebView(frame: .zero, configuration: configuration)
        return webvideo
    }()
    
    
    let webView : UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let title1 : UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .white
        return title
    }()
    
    let description1 : UILabel = {
       let des = UILabel()
        des.font = .systemFont(ofSize: 15, weight: .regular)
        des.translatesAutoresizingMaskIntoConstraints = false
        des.numberOfLines = 0
        des.textColor = .white
        return des
    }()
    
    let downloadbtn : UIButton = {
       let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 10
        button.setTitle("Download", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.addSubview(web)
        view.addSubview(title1)
        view.addSubview(description1)
        view.addSubview(downloadbtn)
        web.navigationDelegate = self
        applyconstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        web.frame = webView.bounds
    }
    
    

    func applyconstraint() {
        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
                                     webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                                     webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     webView.heightAnchor.constraint(equalToConstant: 300)
                                    ])
        
        NSLayoutConstraint.activate([title1.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
                                     title1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                                     title1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
                                    ])
        
        NSLayoutConstraint.activate([description1.topAnchor.constraint(equalTo: title1.bottomAnchor, constant: 8),
                                     description1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                                     description1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
                                    ])
        
        NSLayoutConstraint.activate([downloadbtn.topAnchor.constraint(equalTo: description1.bottomAnchor, constant: 15),
                                     downloadbtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                                     downloadbtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                                     downloadbtn.heightAnchor.constraint(equalToConstant: 60)
                                    ])
    }
    
    
    func databinding(_ data :Movie , youtubeVideoData : VideoElement) {
        title1.text = data.title ?? data.name ?? data.original_name
        description1.text = data.overview
        if let url = URL(string: "https://www.youtube.com/embed/\(youtubeVideoData.id?.videoId ?? "QQjLp1uvQb8")") {
            web.load(URLRequest(url: url))
        }else {
            print("video error")
        }
    }

}
