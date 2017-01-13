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
import SwiftDate

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    private var searchController: UISearchController!
    fileprivate var movies: [NSDictionary]?
    private var refreshControl: UIRefreshControl!
    fileprivate var filteredMovies: [NSDictionary]?
    private var moviesSearchBarPreviouslyFilled: Bool = false
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpSearchController()
        self.setUpMoviesTableView()
        self.loadMoviesData()
        self.setUpRefreshControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDismissed(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlTriggered), for: .valueChanged)
        self.moviesTableView.refreshControl = self.refreshControl
    }
    
    private func setUpMoviesTableView() {
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        self.moviesTableView.backgroundView = UIView(frame: self.moviesTableView.frame)
        self.moviesTableView.backgroundView?.backgroundColor = UIColor.clear
        self.moviesTableView.contentOffset = CGPoint(x: 0, y: self.searchController.searchBar.frame.size.height)
    }
    
    private func setUpSearchController() {
        let searchController: UISearchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.keyboardAppearance = .dark
        definesPresentationContext = true
        self.moviesTableView.tableHeaderView = searchController.searchBar
        self.searchController = searchController
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = moviesNowPlayingForSearchBar
    }
    
    func keyboardDismissed(notification: Notification) {
        self.moviesTableView.contentInset.bottom = 0
    }
    
    func keyboardShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.moviesTableView.contentInset.bottom = keyboardSize.height
        }
    }
    
    func refreshControlTriggered() {
        let url = URL(string: moviesDBNowPlayingEndpoint + moviesDBAPIKey)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    self.updateSearchResults(for: self.searchController)
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
                    self.movies = dataDictionary[moviesResultsPropertyIdentifier] as? [NSDictionary]
                    self.updateSearchResults(for: self.searchController)
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
        if let moviesToShow = self.filteredMovies {
            return moviesToShow.count
        } else {
            return 0
        }
    }
    
    private func parseDate(asString input: String) -> String {
        let date: DateInRegion = try! DateInRegion(string: input, format: .custom("yyyy-MM-dd"))
        let relevantTime = date.string(dateStyle: .medium, timeStyle: .none)
        
        return relevantTime
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: moviesCellReusableIdentifier) as? MoviesTableViewCell
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie[moviesTitlePropertyIdentifier] as! String
        let posterPath = movie[moviesBackdropPathPropertyIdentifier] as! String
        let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
        let releaseDate = self.parseDate(asString: movie[moviesReleaseDatePropertyIdentifier] as! String)
        let rating = movie[moviesVoteAveragePropertyIdentifier] as! Float
        
        cell?.title.text = title
        if !isSearching {
            cell?.moviePosterImageView.alpha = 0.0
            cell?.moviePosterImageView.setImageWith(imageURL as! URL)
            UIView.animate(withDuration: 0.3, animations: { Void in
                cell?.moviePosterImageView.alpha = 1.0
            })
        } else {
            cell?.moviePosterImageView.setImageWith(imageURL as! URL)
        }
        cell?.releaseDateLabel.text = releaseDate
        cell?.ratingLabel.text = String(rating)
        
        return cell!
    }
    
    
    // MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.isSearching = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
        
        // Following is a "hack" to get the refresh control disabled when searching, although it would still work if it wasn't disabled.
        self.moviesTableView.refreshControl = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearching = false
        
        // Following is a "hack" to get the refresh control enabled when done searching.
        self.moviesTableView.refreshControl = self.refreshControl
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            self.filteredMovies = searchText.isEmpty ? self.movies : self.movies!.filter({(dataDict: NSDictionary) -> Bool in
                let returnVal: Bool = (dataDict[moviesTitlePropertyIdentifier] as! String).lowercased().range(of: searchText.lowercased()) != nil
                return returnVal
            })
            
            self.moviesTableView.reloadData()
        }
    }
}
