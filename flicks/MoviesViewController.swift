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
    
    fileprivate var movies: [NSDictionary]?
    fileprivate var filteredMovies: [NSDictionary]?
    private var searchController: UISearchController!
    private var refreshControl: UIRefreshControl!
    private var moviesSearchBarPreviouslyFilled: Bool = false
    private var isSearching: Bool = false
    private var shouldShowLoadingHUD: Bool = false
    var endPoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpSearchController()
        self.setUpMoviesTableView()
        self.shouldShowLoadingHUD = true
        self.loadMoviesData()
        self.shouldShowLoadingHUD = false
        self.setUpRefreshControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDismissed(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Helper methods
    
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.loadMoviesData), for: .valueChanged)
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
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = moviesNowPlayingForSearchBar
    }
    
    @objc private func keyboardDismissed(notification: Notification) {
        self.moviesTableView.contentInset.bottom = 0+(self.tabBarController?.tabBar.frame.height)!
    }
    
    @objc private func keyboardShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.moviesTableView.contentInset.bottom = keyboardSize.height
        }
    }
    
    @objc private func loadMoviesData() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(self.endPoint!)?api_key=\(moviesDBAPIKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        if (self.shouldShowLoadingHUD) {
            self.showHUD()
        }
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
    
    private func parseDate(asString input: String) -> String {
        let date: DateInRegion = try! DateInRegion(string: input, format: .custom("yyyy-MM-dd"))
        let relevantTime = date.string(dateStyle: .medium, timeStyle: .none)
        
        return relevantTime
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let moviesToShow = self.filteredMovies {
            return moviesToShow.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(#function)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: moviesCellReusableIdentifier) as? MoviesTableViewCell
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie[moviesTitlePropertyIdentifier] as? String
        if let posterPath = movie[moviesBackdropPathPropertyIdentifier] as? String {
            let imageURL = NSURL(string: moviesDBBaseImagePath + posterPath)
            if !isSearching {
                cell?.moviePosterImageView.alpha = 0.0
                cell?.moviePosterImageView.setImageWith(imageURL as! URL)
                UIView.animate(withDuration: 0.3, animations: { Void in
                    cell?.moviePosterImageView.alpha = 1.0
                })
            } else {
                cell?.moviePosterImageView.setImageWith(imageURL as! URL)
            }
        }
        let releaseDate = self.parseDate(asString: movie[moviesReleaseDatePropertyIdentifier] as! String)
        let rating = movie[moviesVoteAveragePropertyIdentifier] as! Float
        
        cell?.title.text = title
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
        
        // Following is a "hack" to get the refresh control disabled when searching, although it would still work if it wasn't disabled, it just looks visually better without the refresh control when searching.
        self.moviesTableView.refreshControl = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearching = false
        
        // Following is a "hack" to get the refresh control enabled when done searching.
        self.moviesTableView.refreshControl = self.refreshControl
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell: MoviesTableViewCell = sender as! MoviesTableViewCell   // Might need to change this to UITableViewCell?
        let indexPath: IndexPath? = self.moviesTableView.indexPath(for: cell)
        let movie: NSDictionary = self.filteredMovies![indexPath!.row]
        
        let destinationViewController: MovieDetailsViewController = segue.destination as! MovieDetailsViewController
        destinationViewController.movie = movie
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
