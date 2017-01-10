//
//  MoviesViewController.swift
//  flicks
//
//  Created by Nick McDonald on 1/9/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    private var movies: [NSDictionary]?
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        
        self.loadMoviesData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlTriggered), for: .valueChanged)
        self.moviesTableView.insertSubview(self.refreshControl, at: 0)
    }
    
    func refreshControlTriggered() {
        let url = URL(string: moviesDBNowPlayingEndpoint + moviesDBAPIKey)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
    }

    
    private func loadMoviesData() {
        let url = URL(string: moviesDBNowPlayingEndpoint + moviesDBAPIKey)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        self.showHUD()
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    self.moviesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
            self.hideHUD()
        }
        task.resume()
    }
    
    func showHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
    }
    
    func hideHUD() {
        SVProgressHUD.dismiss()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: moviesCellReusableIdentifier) as? MoviesTableViewCell
        
        let movie = self.movies![indexPath.row]
        let title = movie[moviesTitlePropertyIdentifier] as! String
        let posterPath = movie[moviesBackdropPathPropertyIdentifier] as! String
        let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
        let releaseDate = movie[moviesReleaseDatePropertyIdentifier] as! String
        let rating = movie[moviesVoteAveragePropertyIdentifier] as! Float
        
        cell?.title.text = title
        cell?.moviePosterImageView.setImageWith(imageURL as! URL)
        cell?.releaseDateLabel.text = releaseDate
        cell?.ratingLabel.text = String(rating)
        
        return cell!
        
    }
}
